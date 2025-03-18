import erlang_template/chess/bitboard
import erlang_template/chess/board
import erlang_template/chess/color
import erlang_template/chess/move
import erlang_template/chess/move_tables
import erlang_template/chess/piece
import erlang_template/chess/square
import gleam/int
import gleam/list
import gleam/option
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

  knights
  |> bitboard.map_index(fn(source_i) {
    let source_square = square.from_index_unchecked(source_i)

    let assert Ok(targets) = move_tables.knight_table |> glearray.get(source_i)
    let valid_targets = targets |> int.bitwise_and(not_friendly_pieces)

    use target_i <- bitboard.map_index(valid_targets)
    let target_square = square.from_index_unchecked(target_i)
    let move = move.new(source_square, target_square)
    move
  })
  |> list.flatten
}

pub fn bishop_moves(
  board: board.Board,
  move_tables: move_tables.MoveTables,
) -> List(move.Move) {
  let bishops = board.bitboard(board, piece.Bishop, board.color)
  let blockers = board.all_pieces(board)

  bitboard.map_index(bishops, fn(source_i) {
    let source_square = source_i |> square.from_index_unchecked
    let targets =
      move_tables.bishop_targets(source_square, blockers, move_tables)

    use target_i <- bitboard.map_index(targets)
    let target_square = square.from_index_unchecked(target_i)
    move.new(source_square, target_square)
  })
  |> list.flatten
}

pub fn rook_moves(
  board: board.Board,
  move_tables: move_tables.MoveTables,
) -> List(move.Move) {
  let rooks = board.bitboard(board, piece.Rook, board.color)
  let blockers = board.all_pieces(board)

  bitboard.map_index(rooks, fn(source_i) {
    let source_square = source_i |> square.from_index_unchecked
    let targets = move_tables.rook_targets(source_square, blockers, move_tables)

    use target_i <- bitboard.map_index(targets)
    let target_square = square.from_index_unchecked(target_i)
    move.new(source_square, target_square)
  })
  |> list.flatten
}

pub fn queen_moves(
  board: board.Board,
  move_tables: move_tables.MoveTables,
) -> List(move.Move) {
  let queens = board.bitboard(board, piece.Queen, board.color)
  let blockers = board.all_pieces(board)

  bitboard.map_index(queens, fn(source_i) {
    let source_square = source_i |> square.from_index_unchecked
    let targets =
      int.bitwise_or(
        move_tables.rook_targets(source_square, blockers, move_tables),
        move_tables.bishop_targets(source_square, blockers, move_tables),
      )

    use target_i <- bitboard.map_index(targets)
    let target_square = square.from_index_unchecked(target_i)
    move.new(source_square, target_square)
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

  list.append(
    // Single moves
    bitboard.map_index(single_move_targets, fn(target_i) {
      let source_i = case board.color {
        color.White -> target_i - 8
        color.Black -> target_i + 8
      }
      let source_square = square.from_index_unchecked(source_i)
      let target_square = square.from_index_unchecked(target_i)
      move.new(source_square, target_square)
    }),
    // Double moves
    bitboard.map_index(double_move_targets, fn(target_i) {
      let source_i = case board.color {
        color.White -> target_i - 16
        color.Black -> target_i + 16
      }
      let source_square = square.from_index_unchecked(source_i)
      let target_square = square.from_index_unchecked(target_i)
      move.new(source_square, target_square)
    }),
  )
}

fn shift_forward(bitboard, amount, color) -> Int {
  case color {
    color.White -> int.bitwise_shift_left(bitboard, amount)
    color.Black -> int.bitwise_shift_right(bitboard, amount)
  }
}

// TODO: En passant
pub fn pawn_captures(
  board: board.Board,
  move_tables: move_tables.MoveTables,
) -> List(move.Move) {
  let pawns = board |> board.bitboard(piece.Pawn, board.color)
  let enemies = board |> board.color_bitboard(board.color |> color.inverse)

  let moves =
    bitboard.map_index(pawns, fn(source_i) {
      let assert Ok(targets) =
        case board.color {
          color.White -> move_tables.white_pawn_capture_table
          color.Black -> move_tables.black_pawn_capture_table
        }
        |> glearray.get(source_i)
      let valid_targets = targets |> int.bitwise_and(enemies)

      use target_i <- bitboard.map_index(valid_targets)
      let source_square = square.from_index_unchecked(source_i)
      let target_square = square.from_index_unchecked(target_i)
      move.new(source_square, target_square)
    })
    |> list.flatten

  // En passant
  case board.en_passant {
    option.Some(target_square) -> {
      moves
      |> list.append(
        move_tables.en_passant_source_masks(
          target_square,
          board.color,
          move_tables,
        )
        |> int.bitwise_and(pawns)
        |> bitboard.map_index(fn(source_i) {
          let source_square = square.from_index_unchecked(source_i)
          move.new(source_square, target_square)
        }),
      )
    }
    option.None -> moves
  }
}
