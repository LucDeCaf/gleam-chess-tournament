import erlang_template/chess/board/bitboard
import erlang_template/chess/board/color
import erlang_template/chess/board/move
import erlang_template/chess/board/piece
import erlang_template/chess/board/square
import erlang_template/chess/fen
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
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

pub fn all_pieces(board: Board) {
  let assert Ok(white) = board.pieces |> glearray.get(6)
  let assert Ok(black) = board.pieces |> glearray.get(7)
  int.bitwise_or(white, black)
}

// TODO: What the fuck is this
pub fn piece_at(
  board: Board,
  square square: square.Square,
) -> Option(piece.Piece) {
  let mask = square |> square.index |> bitboard.from_index
  let pawns = board |> piece_bitboard(piece.Pawn) |> int.bitwise_and(mask)
  case pawns != 0 {
    True -> Some(piece.Pawn)
    False -> {
      let knights =
        board |> piece_bitboard(piece.Knight) |> int.bitwise_and(mask)
      case knights != 0 {
        True -> Some(piece.Knight)
        False -> {
          let bishops =
            board |> piece_bitboard(piece.Bishop) |> int.bitwise_and(mask)
          case bishops != 0 {
            True -> Some(piece.Bishop)
            False -> {
              let rooks =
                board |> piece_bitboard(piece.Rook) |> int.bitwise_and(mask)
              case rooks != 0 {
                True -> Some(piece.Rook)
                False -> {
                  let queens =
                    board
                    |> piece_bitboard(piece.Queen)
                    |> int.bitwise_and(mask)
                  case queens != 0 {
                    True -> Some(piece.Queen)
                    False -> {
                      let kings =
                        board
                        |> piece_bitboard(piece.King)
                        |> int.bitwise_and(mask)
                      case kings != 0 {
                        True -> Some(piece.King)
                        False -> None
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
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
      let assert Some(moved_piece) = board |> piece_at(source)

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

  let friendly_bitboard = board |> color_bitboard(board.color)
  let enemy_bitboard = board |> color_bitboard(board.color |> color.inverse)

  let new_pawn_bitboard =
    board
    |> piece_bitboard(piece.Pawn)
    |> int.bitwise_exclusive_or(source_bb)
  let new_promotion_piece_bitboard =
    board
    |> piece_bitboard(promotion_piece)
    |> int.bitwise_or(target_bb)
  let promotion_bitboard_i = promotion_piece |> piece.index

  let new_friendly_bitboard =
    friendly_bitboard
    |> int.bitwise_exclusive_or(int.bitwise_or(source_bb, target_bb))
  let new_enemy_bitboard = case is_capture {
    True -> enemy_bitboard |> int.bitwise_exclusive_or(target_i)
    False -> enemy_bitboard
  }

  let color_bitboards = case board.color {
    color.White -> #(new_friendly_bitboard, new_enemy_bitboard)
    color.Black -> #(new_enemy_bitboard, new_friendly_bitboard)
  }

  let new_captured_piece_bitboard = case captured_piece {
    Some(captured_piece) -> {
      case captured_piece == promotion_piece {
        True -> new_promotion_piece_bitboard
        False ->
          board
          |> piece_bitboard(captured_piece)
          |> int.bitwise_exclusive_or(target_bb)
      }
    }
    // Will be unused
    None -> {
      0
    }
  }

  let captured_bitboard_i = case captured_piece {
    Some(piece) -> piece |> piece.index
    None -> -1
  }

  let pieces =
    board.pieces
    |> glearray.to_list
    |> list.index_map(fn(bitboard, i) {
      case i {
        // Replace pawns with new bb
        0 -> new_pawn_bitboard
        // Replace promoted piece bb
        i if i == promotion_bitboard_i -> new_promotion_piece_bitboard
        // Replace captured piece bb
        i if i == captured_bitboard_i -> new_captured_piece_bitboard
        // White pieces
        6 -> color_bitboards.0
        // Black pieces
        7 -> color_bitboards.1
        // Just copy bb for most
        _ -> bitboard
      }
    })
    |> glearray.from_list

  Board(
    pieces: pieces,
    color: board.color |> color.inverse,
    // TODO: Adjust castling rights if capturing a rook
    castling_rights: board.castling_rights,
    en_passant: None,
  )
}

// TODO: Tests
fn handle_castle(board: Board, target: square.Square) -> Board {
  let #(source, rook_mask, removed_castling_right) = case target {
    square.G1 -> #(square.E1, 0xa0, 0b0001)
    square.C1 -> #(square.E1, 0x9, 0b0010)
    square.G8 -> #(square.E8, 0xa000000000000000, 0b0100)
    square.C8 -> #(square.E8, 0x900000000000000, 0b1000)
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
    board.castling_rights |> int.bitwise_exclusive_or(removed_castling_right)

  Board(
    pieces: pieces,
    color: board.color |> color.inverse,
    castling_rights: castling_rights,
    en_passant: None,
  )
}

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

fn handle_normal_move(
  board: Board,
  source: square.Square,
  target: square.Square,
  moved_piece: piece.Piece,
) -> Board {
  todo
}

pub fn is_legal_move(board: Board, move: move.Move) -> Bool {
  // TODO: Legal move checker
  True
}
