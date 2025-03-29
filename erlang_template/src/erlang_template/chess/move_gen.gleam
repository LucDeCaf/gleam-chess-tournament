import erlang_template/chess/board
import erlang_template/chess/board/bitboard
import erlang_template/chess/board/color
import erlang_template/chess/board/flags
import erlang_template/chess/board/move
import erlang_template/chess/board/piece
import erlang_template/chess/board/square
import erlang_template/chess/tables/move_tables
import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{None, Some}

pub fn attacks_to(
  board: board.Board,
  square: square.Square,
  move_tables: move_tables.MoveTables,
) -> Int {
  let knights = board |> board.piece_bitboard(piece.Knight)
  let kings = board |> board.piece_bitboard(piece.King)
  let rooks = board |> board.piece_bitboard(piece.Rook)
  let bishops = board |> board.piece_bitboard(piece.Bishop)
  let queens = board |> board.piece_bitboard(piece.Queen)
  let rooks_queens = queens |> int.bitwise_or(rooks)
  let bishops_queens = queens |> int.bitwise_or(bishops)
  let white_pawns = board |> board.bitboard(piece.Pawn, color.White)
  let black_pawns = board |> board.bitboard(piece.Pawn, color.Black)

  let knight_attacks = move_tables.knight_targets(square)
  let king_attacks = move_tables.king_targets(square)
  let white_pawn_attacks = move_tables.white_pawn_capture_targets(square)
  let black_pawn_attacks = move_tables.black_pawn_capture_targets(square)

  let blockers = board |> board.all_pieces
  let rook_queen_attacks =
    move_tables.sliding_targets(square, blockers, move_tables.rook_move_shifts)
  let bishop_queen_attacks =
    move_tables.sliding_targets(
      square,
      blockers,
      move_tables.bishop_move_shifts,
    )

  let attacking_knights = knight_attacks |> int.bitwise_and(knights)
  let attacking_kings = king_attacks |> int.bitwise_and(kings)
  let attacking_white_pawns = black_pawn_attacks |> int.bitwise_and(white_pawns)
  let attacking_black_pawns = white_pawn_attacks |> int.bitwise_and(black_pawns)
  let attacking_rooks_queens =
    rook_queen_attacks |> int.bitwise_and(rooks_queens)
  let attacking_bishops_queens =
    bishop_queen_attacks |> int.bitwise_and(bishops_queens)

  attacking_knights
  |> int.bitwise_or(attacking_kings)
  |> int.bitwise_or(attacking_white_pawns)
  |> int.bitwise_or(attacking_black_pawns)
  |> int.bitwise_or(attacking_rooks_queens)
  |> int.bitwise_or(attacking_bishops_queens)
}

// TODO: Optimise with guard clauses
pub fn square_attacked_by(
  board: board.Board,
  square: square.Square,
  color: color.Color,
  tables: move_tables.MoveTables,
) -> Bool {
  // Knights and kings are cheapest to check
  let enemy_knights = board |> board.bitboard(piece.Knight, color)
  let knights = tables.knight_targets(square) |> int.bitwise_and(enemy_knights)
  use <- bool.guard(when: knights != 0, return: True)

  let enemy_kings = board |> board.bitboard(piece.King, color)
  let kings = tables.king_targets(square) |> int.bitwise_and(enemy_kings)
  use <- bool.guard(when: kings != 0, return: True)

  // Pawns are next cheapest
  let enemy_pawns = board |> board.bitboard(piece.Pawn, color)
  let pawns =
    case color {
      color.White -> tables.black_pawn_capture_targets(square)
      color.Black -> tables.white_pawn_capture_targets(square)
    }
    |> int.bitwise_and(enemy_pawns)
  use <- bool.guard(when: pawns != 0, return: True)

  // Diagonal attackers (bishops and queens)
  let enemy_bishops = board |> board.bitboard(piece.Bishop, color)
  let enemy_queens = board |> board.bitboard(piece.Queen, color)
  let enemy_diagonals = enemy_bishops |> int.bitwise_or(enemy_queens)
  let blockers = board |> board.all_pieces

  let diagonals =
    move_tables.sliding_targets(
      square,
      blockers,
      move_tables.bishop_move_shifts,
    )
    |> int.bitwise_and(enemy_diagonals)
  use <- bool.guard(when: diagonals != 0, return: True)

  // Horizontal attackers (rooks and queens)
  let enemy_rooks = board |> board.bitboard(piece.Rook, color)
  let enemy_horizontals = enemy_rooks |> int.bitwise_or(enemy_queens)

  let horizontals =
    move_tables.sliding_targets(square, blockers, move_tables.rook_move_shifts)
    |> int.bitwise_and(enemy_horizontals)

  horizontals != 0
}

pub fn is_check(board, mt) {
  square_attacked_by(
    board,
    board.king_square(board, board.color),
    board.color |> color.inverse,
    mt,
  )
}

pub fn legal_moves(board, move_tables) -> List(move.Move) {
  let all_moves = pseudolegal_moves(board, move_tables)
  use move <- list.filter(all_moves)
  is_legal_move(board, move, move_tables)
}

pub fn pseudolegal_moves(board: board.Board, move_tables) -> List(move.Move) {
  let knight_moves = knight_moves(board, move_tables)
  let bishop_moves = bishop_moves(board)
  let rook_moves = rook_moves(board)
  let queen_moves = queen_moves(board, move_tables)
  let king_moves = king_moves(board, move_tables)
  let castling_moves = castling_moves(board, move_tables)
  let pawn_moves = pawn_straight_moves(board)
  let pawn_captures = pawn_captures(board, move_tables)

  knight_moves
  |> list.append(bishop_moves)
  |> list.append(rook_moves)
  |> list.append(queen_moves)
  |> list.append(king_moves)
  |> list.append(castling_moves)
  |> list.append(pawn_moves)
  |> list.append(pawn_captures)
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

    let targets = move_tables.knight_targets(source)
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
  // move_tables: move_tables.MoveTables,
) -> List(move.Move) {
  let bishops = board.bitboard(board, piece.Bishop, board.color)
  let friendly_pieces = board |> board.color_bitboard(board.color)
  let not_friendly_pieces = int.bitwise_not(friendly_pieces)
  let enemy_pieces = board |> board.color_bitboard(board.color |> color.inverse)
  let blockers = int.bitwise_or(friendly_pieces, enemy_pieces)

  bitboard.map_index(bishops, fn(source_i) {
    let source = source_i |> square.from_index_unchecked
    let targets =
      move_tables.sliding_targets(
        source,
        blockers,
        move_tables.bishop_move_shifts,
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

pub fn rook_moves(
  board: board.Board,
  // move_tables: move_tables.MoveTables,
) -> List(move.Move) {
  let rooks = board.bitboard(board, piece.Rook, board.color)
  let friendly_pieces = board |> board.color_bitboard(board.color)
  let not_friendly_pieces = int.bitwise_not(friendly_pieces)
  let enemy_pieces = board |> board.color_bitboard(board.color |> color.inverse)
  let blockers = int.bitwise_or(friendly_pieces, enemy_pieces)

  bitboard.map_index(rooks, fn(source_i) {
    let source = source_i |> square.from_index_unchecked
    let targets =
      move_tables.sliding_targets(
        source,
        blockers,
        move_tables.rook_move_shifts,
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
      move_tables.sliding_targets(
        source,
        blockers,
        move_tables.queen_move_shifts,
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
      let source = square.from_index_unchecked(source_i)
      let targets = case board.color {
        color.White -> move_tables.white_pawn_capture_targets(source)
        color.Black -> move_tables.black_pawn_capture_targets(source)
      }
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
pub fn king_moves(board: board.Board, move_tables: move_tables.MoveTables) {
  let kings = board.bitboard(board, piece.King, board.color)
  let friendly_pieces = board.color_bitboard(board, board.color)
  let not_friendly_pieces = int.bitwise_not(friendly_pieces)
  let enemy_pieces = board.color_bitboard(board, board.color |> color.inverse)

  kings
  |> bitboard.map_index(fn(source_i) {
    let source = square.from_index_unchecked(source_i)

    let targets = move_tables.king_targets(source)
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

pub fn castling_moves(board: board.Board, tables: move_tables.MoveTables) {
  let can_kingside = can_castle_kingside(board, tables)
  let can_queenside = can_castle_queenside(board, tables)

  let kingside = case can_kingside {
    True -> [
      case board.color {
        color.White -> move.new(square.E1, square.G1, flags.castle_kingside)
        color.Black -> move.new(square.E8, square.G8, flags.castle_kingside)
      },
    ]
    False -> []
  }

  let queenside = case can_queenside {
    True -> [
      case board.color {
        color.White -> move.new(square.E1, square.C1, flags.castle_queenside)
        color.Black -> move.new(square.E8, square.C8, flags.castle_queenside)
      },
    ]
    False -> []
  }

  list.append(kingside, queenside)
}

fn can_castle_kingside(board: board.Board, tables) -> Bool {
  can_castle(
    board,
    #(0b0001, 0b0100),
    #([square.F1, square.G1], [square.F8, square.G8]),
    #([square.F1, square.G1], [square.F8, square.G8]),
    tables,
  )
}

fn can_castle_queenside(board: board.Board, tables) -> Bool {
  can_castle(
    board,
    #(0b0010, 0b1000),
    #([square.D1, square.C1, square.B1], [square.D8, square.C8, square.B8]),
    #([square.D1, square.C1], [square.D8, square.C8]),
    tables,
  )
}

/// Generic function for checking for castling validity in either direction (kingside or queenside)
fn can_castle(
  board: board.Board,
  rights_masks: #(Int, Int),
  blockers: #(List(square.Square), List(square.Square)),
  check_squares: #(List(square.Square), List(square.Square)),
  tables,
) {
  // Must have valid castling rights
  let rights_mask = case board.color {
    color.White -> rights_masks.0
    color.Black -> rights_masks.1
  }
  let has_kingside_right =
    int.bitwise_and(board.castling_rights, rights_mask) != 0

  use <- bool.guard(when: !has_kingside_right, return: False)

  // Can't castle through pieces
  let blockers = case board.color {
    color.White -> blockers.0
    color.Black -> blockers.1
  }

  use <- bool.guard(when: !squares_empty(board, blockers), return: False)

  // Can't castle into / out of / through check
  let enemy_color = board.color |> color.inverse
  let king_square = case board.color {
    color.White -> square.E1
    color.Black -> square.E8
  }
  let check_squares = case board.color {
    color.White -> check_squares.0
    color.Black -> check_squares.1
  }
  let castle_squares = [king_square, ..check_squares]

  use castle_square <- list.all(castle_squares)
  !{ board |> square_attacked_by(castle_square, enemy_color, tables) }
}

pub fn squares_empty(board, squares) {
  let mask =
    squares
    |> list.map(square.bitboard)
    |> list.fold(0, int.bitwise_or)

  int.bitwise_and(board.all_pieces(board), mask) == 0
}

// TODO: Optimise to not have to play the move to check if it is legal
pub fn is_legal_move(
  board: board.Board,
  move: move.Move,
  tables: move_tables.MoveTables,
) -> Bool {
  let board_after_move = board |> board.make_move(move)
  let king_square = board.king_square(board_after_move, board.color)

  let king_can_be_captured =
    board_after_move
    |> square_attacked_by(king_square, board_after_move.color, tables)

  !king_can_be_captured
}
