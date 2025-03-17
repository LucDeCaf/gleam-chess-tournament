import erlang_template/chess/color
import erlang_template/chess/move
import erlang_template/chess/piece
import gleam/int
import glearray

pub type Board {
  Board(pieces: glearray.Array(Int), color: color.Color, castling_rights: Int)
}

pub fn piece_bitboard(board: Board, piece: piece.Piece) {
  let assert Ok(bitboard) = glearray.get(board.pieces, piece.index(piece))
  bitboard
}

pub fn color_bitboard(board: Board, color: color.Color) {
  let assert Ok(bitboard) = glearray.get(board.pieces, color.index(color) + 6)
  bitboard
}

pub fn bitboard(board: Board, piece: piece.Piece, color: color.Color) {
  int.bitwise_and(piece_bitboard(board, piece), color_bitboard(board, color))
}

pub fn is_legal_move(board: Board, move: move.Move) -> Bool {
  // TODO: Legal move checker
  True
}
