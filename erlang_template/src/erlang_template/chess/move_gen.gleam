import erlang_template/chess/board
import erlang_template/chess/board/bitboard
import erlang_template/chess/board/color
import erlang_template/chess/board/flags
import erlang_template/chess/board/move
import erlang_template/chess/board/piece
import erlang_template/chess/board/square
import erlang_template/chess/move_gen/move_tables
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import glearray

pub fn legal_moves(board: board.Board, move_tables) -> List(move.Move) {
  list.filter(pseudolegal_moves(board, move_tables), fn(move) {
    board.is_legal_move(board, move)
  })
}

fn pseudolegal_moves(board: board.Board, move_tables) -> List(move.Move) {
  // TODO: Move generator
  let knight_moves = knight_moves(board, move_tables)

  knight_moves
}

pub fn knight_moves(
  board: board.Board,
  move_tables: move_tables.MoveTables,
) -> List(move.Move) {
  let knights = board.bitboard(board, piece.Knight, board.color)
  let friendly_pieces = board.color_bitboard(board, board.color)
  let not_friendly_pieces = int.bitwise_not(friendly_pieces)
  let enemy_pieces = board.color_bitboard(board, board.color |> color.inverse)

  knights
  |> bitboard.map_index(fn(source_i) {
    let source = square.from_index_unchecked(source_i)

    let assert Ok(targets) = move_tables.knight_table |> glearray.get(source_i)
    let valid_targets = targets |> int.bitwise_and(not_friendly_pieces)

    use target_i <- bitboard.map_index(valid_targets)
    let target = square.from_index_unchecked(target_i)
    let is_capture =
      {
        bitboard.from_index(target_i)
        |> int.bitwise_and(enemy_pieces)
      }
      != 0

    move.new(source, target, flags.new(None, is_capture, 0))
  })
  |> list.flatten
}

pub fn bishop_moves(
  board: board.Board,
  move_tables: move_tables.MoveTables,
) -> List(move.Move) {
  let bishops = board.bitboard(board, piece.Bishop, board.color)
  let friendly_pieces = board |> board.color_bitboard(board.color)
  let not_friendly_pieces = board |> board.color_bitboard(board.color)
  let enemy_pieces = board |> board.color_bitboard(board.color |> color.inverse)
  let blockers = int.bitwise_or(friendly_pieces, enemy_pieces)

  bitboard.map_index(bishops, fn(source_i) {
    let source = source_i |> square.from_index_unchecked
    let targets =
      move_tables.bishop_targets(source, blockers, move_tables)
      |> int.bitwise_and(not_friendly_pieces)

    use target_i <- bitboard.map_index(targets)
    let is_capture =
      {
        bitboard.from_index(target_i)
        |> int.bitwise_and(enemy_pieces)
      }
      != 0
    let target = square.from_index_unchecked(target_i)
    move.new(source, target, flags.new(None, is_capture, 0))
  })
  |> list.flatten
}

pub fn rook_moves(
  board: board.Board,
  move_tables: move_tables.MoveTables,
) -> List(move.Move) {
  let rooks = board.bitboard(board, piece.Rook, board.color)
  let friendly_pieces = board |> board.color_bitboard(board.color)
  let not_friendly_pieces = board |> board.color_bitboard(board.color)
  let enemy_pieces = board |> board.color_bitboard(board.color |> color.inverse)
  let blockers = int.bitwise_or(friendly_pieces, enemy_pieces)

  bitboard.map_index(rooks, fn(source_i) {
    let source = source_i |> square.from_index_unchecked
    let targets =
      move_tables.rook_targets(source, blockers, move_tables)
      |> int.bitwise_and(not_friendly_pieces)

    use target_i <- bitboard.map_index(targets)
    let is_capture =
      {
        bitboard.from_index(target_i)
        |> int.bitwise_and(enemy_pieces)
      }
      != 0
    let target = square.from_index_unchecked(target_i)
    move.new(source, target, flags.new(None, is_capture, 0))
  })
  |> list.flatten
}

pub fn queen_moves(
  board: board.Board,
  move_tables: move_tables.MoveTables,
) -> List(move.Move) {
  let queens = board.bitboard(board, piece.Queen, board.color)
  let friendly_pieces = board.color_bitboard(board, board.color)
  let not_friendly_pieces = int.bitwise_not(friendly_pieces)
  let enemy_pieces = board.color_bitboard(board, board.color |> color.inverse)
  let blockers = int.bitwise_or(friendly_pieces, enemy_pieces)

  bitboard.map_index(queens, fn(source_i) {
    let source = source_i |> square.from_index_unchecked
    let targets =
      int.bitwise_or(
        move_tables.rook_targets(source, blockers, move_tables),
        move_tables.bishop_targets(source, blockers, move_tables),
      )
      |> int.bitwise_and(not_friendly_pieces)

    use target_i <- bitboard.map_index(targets)
    let is_capture =
      {
        bitboard.from_index(target_i)
        |> int.bitwise_and(enemy_pieces)
      }
      != 0
    let target = square.from_index_unchecked(target_i)
    move.new(source, target, flags.new(None, is_capture, 0))
  })
  |> list.flatten
}

pub fn pawn_straight_moves(board: board.Board) -> List(move.Move) {
  let pawns = board.bitboard(board, piece.Pawn, board.color)
  let blockers = board.all_pieces(board)

  // No need to force U64 size - pawns' max index is 55 (H7)
  let single_move_targets =
    pawns
    |> shift_forward(8, board.color)
    |> int.bitwise_and(int.bitwise_not(blockers))

  let promotion_targets =
    single_move_targets
    |> int.bitwise_and(case board.color {
      // 8th rank
      color.White -> 0xff00000000000000
      // 1st rank
      color.Black -> 0x00000000000000ff
    })

  // Handle promotions and regular pushes separately
  let single_move_targets =
    single_move_targets |> int.bitwise_and(int.bitwise_not(promotion_targets))

  let unmoved_pawns =
    pawns
    |> int.bitwise_and(case board.color {
      color.White -> 0x000000000000ff00
      color.Black -> 0x00ff000000000000
    })
  let double_move_targets =
    unmoved_pawns
    // Unblocked single moves
    |> shift_forward(8, board.color)
    |> int.bitwise_and(int.bitwise_not(blockers))
    // Unblocked double moves
    |> shift_forward(8, board.color)
    |> int.bitwise_and(int.bitwise_not(blockers))

  // Single moves
  bitboard.map_index(single_move_targets, fn(target_i) {
    let source_i = case board.color {
      color.White -> target_i - 8
      color.Black -> target_i + 8
    }
    let source = square.from_index_unchecked(source_i)
    let target = square.from_index_unchecked(target_i)
    move.new(source, target, flags.new(None, False, 0))
  })
  // Double moves
  |> list.append(
    bitboard.map_index(double_move_targets, fn(target_i) {
      let source_i = case board.color {
        color.White -> target_i - 16
        color.Black -> target_i + 16
      }
      let source = square.from_index_unchecked(source_i)
      let target = square.from_index_unchecked(target_i)
      move.new(source, target, flags.new(None, False, flags.double_move))
    }),
  )
  // Promotions
  |> list.append(
    bitboard.map_index(promotion_targets, fn(target_i) {
      let source_i = case board.color {
        color.White -> target_i - 8
        color.Black -> target_i + 8
      }
      let source = square.from_index_unchecked(source_i)
      let target = square.from_index_unchecked(target_i)
      use piece <- list.map(piece.valid_promotion_pieces)
      move.new(source, target, flags.new(Some(piece), False, 0))
    })
    |> list.flatten,
  )
}

fn shift_forward(bitboard, amount, color) -> Int {
  case color {
    color.White -> int.bitwise_shift_left(bitboard, amount)
    color.Black -> int.bitwise_shift_right(bitboard, amount)
  }
}

pub fn pawn_captures(
  board: board.Board,
  move_tables: move_tables.MoveTables,
) -> List(move.Move) {
  let pawns = board |> board.bitboard(piece.Pawn, board.color)
  let enemies = board |> board.color_bitboard(board.color |> color.inverse)

  // Captures
  let moves =
    bitboard.map_index(pawns, fn(source_i) {
      let assert Ok(targets) =
        case board.color {
          color.White -> move_tables.white_pawn_capture_table
          color.Black -> move_tables.black_pawn_capture_table
        }
        |> glearray.get(source_i)
      let valid_targets = targets |> int.bitwise_and(enemies)

      let is_promotion =
        square.rank(source_i)
        == case board.color {
          color.White -> 6
          color.Black -> 1
        }

      case is_promotion {
        // Promotion - will generate [[left_capture_promotions], [right_capture_promotions]] |> flatten
        True -> {
          valid_targets
          |> bitboard.map_index(fn(target_i) {
            let source = square.from_index_unchecked(source_i)
            let target = square.from_index_unchecked(target_i)
            use piece <- list.map(piece.valid_promotion_pieces)
            move.new(source, target, flags.new(Some(piece), False, 0))
          })
          |> list.flatten
        }
        // Not a promotion - will generate [left_capture, right_capture]
        False -> {
          use target_i <- bitboard.map_index(valid_targets)
          let source = square.from_index_unchecked(source_i)
          let target = square.from_index_unchecked(target_i)
          move.new(source, target, flags.new(None, True, 0))
        }
      }
    })
    |> list.flatten

  // En passant
  case board.en_passant {
    Some(target) -> {
      moves
      |> list.append(
        move_tables.en_passant_source_masks(target, board.color, move_tables)
        |> int.bitwise_and(pawns)
        |> bitboard.map_index(fn(source_i) {
          let source = square.from_index_unchecked(source_i)
          move.new(source, target, flags.new(None, True, flags.en_passant))
        }),
      )
    }
    None -> moves
  }
}
// TODO: Castling
