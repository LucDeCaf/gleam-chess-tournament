import erlang_template/chess/board/bitboard
import erlang_template/chess/board/color
import erlang_template/chess/board/move
import erlang_template/chess/board/piece
import erlang_template/chess/board/square
import erlang_template/chess/fen
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import glearray

pub type Board {
  Board(
    pieces: glearray.Array(Int),
    color: color.Color,
    castling_rights: Int,
    en_passant: Option(square.Square),
  )
}

pub fn piece_bitboard(board: Board, piece: piece.Piece) {
  let assert Ok(bitboard) = glearray.get(board.pieces, piece.index(piece))
  bitboard
}

pub fn color_bitboard(board: Board, color: color.Color) {
  let assert Ok(bitboard) = glearray.get(board.pieces, color.index(color) + 6)
  bitboard
}

pub fn has_kingside_castling_rights(board: Board, color) {
  board.castling_rights
  |> int.bitwise_and(case color {
    color.White -> 0b0001
    color.Black -> 0b0100
  })
  != 0
}

pub fn all_pieces(board: Board) {
  let assert Ok(white) = board.pieces |> glearray.get(6)
  let assert Ok(black) = board.pieces |> glearray.get(7)
  int.bitwise_or(white, black)
}

// TODO: Tests
pub fn piece_at(board: Board, square: square.Square) {
  let mask = square |> square.bitboard
  board.pieces
  |> glearray.to_list
  |> list.index_map(fn(bitboard, i) {
    case bitboard |> int.bitwise_and(mask) {
      0 -> None
      _ -> piece.from_index(i) |> option.from_result
    }
  })
  |> list.find(option.is_some)
  |> result.unwrap(or: None)
}

pub fn bitboard(board: Board, piece: piece.Piece, color: color.Color) {
  int.bitwise_and(piece_bitboard(board, piece), color_bitboard(board, color))
}

pub fn from_fen(fen: String) -> Board {
  Board(
    pieces: fen.pieces(fen),
    color: fen.color(fen),
    castling_rights: fen.castling_rights(fen),
    en_passant: fen.en_passant(fen),
  )
}

pub fn make_move(on board: Board, play move: move.Move) -> Board {
  let source = move |> move.source
  let target = move |> move.target
  let promotion = move |> move.promotion

  case promotion {
    Some(promotion_piece) -> {
      handle_promotion(board, source, target, promotion_piece)
    }

    None -> {
      let moved_piece = case board |> piece_at(source) {
        Some(piece) -> piece
        None ->
          panic as {
            "no piece found at "
            <> square.to_string(source)
            <> " ("
            <> move.to_debug_string(move)
            <> ")"
          }
      }

      let source_i = source |> square.index
      let target_i = target |> square.index
      let file_start = source_i |> square.file
      let file_end = target_i |> square.file
      let file_diff = int.absolute_value(file_start - file_end)

      case moved_piece == piece.King && file_diff == 2 {
        True -> handle_castle(board, target)

        False -> {
          case board.en_passant {
            Some(ep) ->
              case target == ep && moved_piece == piece.Pawn {
                True -> handle_en_passant(board, source, target)

                False -> handle_normal_move(board, source, target, moved_piece)
              }

            None -> {
              handle_normal_move(board, source, target, moved_piece)
            }
          }
        }
      }
    }
  }
}

// TODO: Tests
fn handle_promotion(
  board: Board,
  source: square.Square,
  target: square.Square,
  promotion_piece: piece.Piece,
) {
  let source_i = source |> square.index
  let target_i = target |> square.index
  let source_bb = source_i |> bitboard.from_index
  let target_bb = target_i |> bitboard.from_index

  let captured_piece = board |> piece_at(target)
  let is_capture = option.is_some(captured_piece)

  let pawn_mask = source_bb
  let promotion_piece_mask = target_bb
  let promotion_bb_i = promotion_piece |> piece.index

  let friendly_bitboard_mask = int.bitwise_or(source_bb, target_bb)
  let enemy_bitboard_mask = case is_capture {
    True -> target_i
    False -> 0
  }

  let #(captured_piece_mask, captured_bb_i) = case captured_piece {
    Some(piece) -> #(target_bb, piece |> piece.index)
    None -> #(0, -1)
  }

  let #(friendly_bb_index, enemy_bb_index) = case board.color {
    color.White -> #(6, 7)
    color.Black -> #(7, 6)
  }

  let pieces =
    board.pieces
    |> glearray.to_list
    |> list.index_map(fn(bitboard, i) {
      int.bitwise_exclusive_or(bitboard, case i {
        0 -> pawn_mask
        i if i == promotion_bb_i -> promotion_piece_mask
        i if i == captured_bb_i -> captured_piece_mask
        i if i == friendly_bb_index -> friendly_bitboard_mask
        i if i == enemy_bb_index -> enemy_bitboard_mask
        _ -> 0
      })
    })
    |> glearray.from_list

  let removed_castling_rights = case target {
    square.H1 -> 0b0001
    square.A1 -> 0b0010
    square.H8 -> 0b0100
    square.A8 -> 0b1000
    _ -> 0
  }
  let castling_rights =
    board.castling_rights
    |> int.bitwise_and(int.bitwise_not(removed_castling_rights))

  Board(
    pieces: pieces,
    color: board.color |> color.inverse,
    castling_rights: castling_rights,
    en_passant: None,
  )
}

// TODO: Tests
fn handle_castle(board: Board, target: square.Square) -> Board {
  let #(source, rook_mask, removed_castling_right) = case target {
    square.G1 -> #(square.E1, 0xa0, 0b0011)
    square.C1 -> #(square.E1, 0x9, 0b0011)
    square.G8 -> #(square.E8, 0xa000000000000000, 0b1100)
    square.C8 -> #(square.E8, 0x900000000000000, 0b1100)
    _ -> panic as { "invalid castling target: " <> square.to_string(target) }
  }

  let king_mask =
    int.bitwise_or(source |> square.bitboard, target |> square.bitboard)

  let friendly_color_mask = rook_mask |> int.bitwise_or(king_mask)

  let friendly_bb_index = case board.color {
    color.White -> 6
    color.Black -> 7
  }

  let pieces =
    board.pieces
    |> glearray.to_list
    |> list.index_map(fn(bitboard, i) {
      case i {
        3 -> bitboard |> int.bitwise_exclusive_or(rook_mask)
        5 -> bitboard |> int.bitwise_exclusive_or(king_mask)
        i if i == friendly_bb_index ->
          bitboard |> int.bitwise_exclusive_or(friendly_color_mask)
        _ -> bitboard
      }
    })
    |> glearray.from_list

  let castling_rights =
    board.castling_rights
    |> int.bitwise_and(int.bitwise_not(removed_castling_right))

  Board(
    pieces: pieces,
    color: board.color |> color.inverse,
    castling_rights: castling_rights,
    en_passant: None,
  )
}

// TODO: Tests
fn handle_en_passant(
  board: Board,
  source: square.Square,
  target: square.Square,
) -> Board {
  let target_i = target |> square.index
  let source_bb = source |> square.bitboard
  let target_bb = target |> square.bitboard

  let captured_pawn_i = case board.color {
    color.White -> target_i - 8
    color.Black -> target_i + 8
  }
  let captured_pawn_bb = bitboard.from_index(captured_pawn_i)

  let pawn_mask =
    source_bb
    |> int.bitwise_or(target_bb)
    |> int.bitwise_or(captured_pawn_bb)
  let friendly_color_mask = source_bb |> int.bitwise_or(target_bb)
  let enemy_color_mask = captured_pawn_bb

  let #(friendly_bb_index, enemy_bb_index) = case board.color {
    color.White -> #(6, 7)
    color.Black -> #(7, 6)
  }

  let pieces =
    board.pieces
    |> glearray.to_list
    |> list.index_map(fn(bitboard, i) {
      case i {
        0 -> int.bitwise_exclusive_or(bitboard, pawn_mask)
        i if i == friendly_bb_index ->
          int.bitwise_exclusive_or(bitboard, friendly_color_mask)
        i if i == enemy_bb_index ->
          int.bitwise_exclusive_or(bitboard, enemy_color_mask)
        _ -> bitboard
      }
    })
    |> glearray.from_list

  Board(
    pieces: pieces,
    color: board.color |> color.inverse,
    castling_rights: board.castling_rights,
    en_passant: None,
  )
}

// TODO: Tests
fn handle_normal_move(
  board: Board,
  source: square.Square,
  target: square.Square,
  moved_piece: piece.Piece,
) -> Board {
  let captured_piece = board |> piece_at(target)

  let source_i = source |> square.index
  let target_i = target |> square.index
  let source_bb = source_i |> bitboard.from_index
  let target_bb = target_i |> bitboard.from_index

  let moved_piece_mask = source_bb |> int.bitwise_or(target_bb)
  let moved_bb_i = moved_piece |> piece.index

  let #(captured_piece_mask, captured_bb_i) = case captured_piece {
    Some(piece) -> #(target_bb, piece |> piece.index)
    None -> #(0, -1)
  }

  let #(friendly_bb_index, enemy_bb_index) = case board.color {
    color.White -> #(6, 7)
    color.Black -> #(7, 6)
  }

  let pieces =
    board.pieces
    |> glearray.to_list
    |> list.index_map(fn(bitboard, i) {
      int.bitwise_exclusive_or(bitboard, case i {
        i if i == moved_bb_i -> moved_piece_mask
        i if i == captured_bb_i -> captured_piece_mask
        i if i == friendly_bb_index -> moved_piece_mask
        i if i == enemy_bb_index -> captured_piece_mask
        _ -> 0
      })
    })
    |> glearray.from_list

  let removed_castling_rights = case moved_piece {
    // King move - remove all rights
    piece.King ->
      case board.color {
        color.White -> 0b0011
        color.Black -> 0b1100
      }
    _ ->
      // Captured rook
      case target {
        square.H1 -> 0b0001
        square.A1 -> 0b0010
        square.H8 -> 0b0100
        square.A8 -> 0b1000
        _ -> 0
      }
      // Rook moves
      |> int.bitwise_or(case source {
        square.H1 -> 0b0001
        square.A1 -> 0b0010
        square.H8 -> 0b0100
        square.A8 -> 0b1000
        _ -> 0
      })
  }

  let castling_rights =
    board.castling_rights
    |> int.bitwise_and(int.bitwise_not(removed_castling_rights))

  let en_passant = case
    moved_piece == piece.Pawn && is_double_move(source, target)
  {
    True -> en_passant_square(source)
    False -> None
  }

  Board(pieces, board.color |> color.inverse, castling_rights, en_passant)
}

fn is_double_move(source, target) {
  int.absolute_value(
    { source |> square.index |> square.rank }
    - { target |> square.index |> square.rank },
  )
  == 2
}

fn en_passant_square(source) {
  let source_i = source |> square.index
  case source_i |> square.rank {
    1 -> source_i + 8 |> square.from_index |> option.from_result
    6 -> source_i - 8 |> square.from_index |> option.from_result
    _ -> None
  }
}
