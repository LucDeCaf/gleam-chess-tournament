import erlang_template/chess/board
import erlang_template/chess/board/bitboard
import erlang_template/chess/board/color
import erlang_template/chess/board/piece

const pawn_value = 100

const knight_value = 300

const bishop_value = 320

const rook_value = 500

const queen_value = 900

fn count_material(board: board.Board) {
  // TODO: Technically a bit suboptimal as board.color_bitboard is called multiple times
  let white_pawns =
    { board.bitboard(board, piece.Pawn, color.White) |> bitboard.popcount }
    * pawn_value
  let white_knights =
    { board.bitboard(board, piece.Knight, color.White) |> bitboard.popcount }
    * knight_value
  let white_bishops =
    { board.bitboard(board, piece.Bishop, color.White) |> bitboard.popcount }
    * bishop_value
  let white_rooks =
    { board.bitboard(board, piece.Rook, color.White) |> bitboard.popcount }
    * rook_value
  let white_queens =
    { board.bitboard(board, piece.Queen, color.White) |> bitboard.popcount }
    * queen_value

  let black_pawns =
    { board.bitboard(board, piece.Pawn, color.Black) |> bitboard.popcount }
    * pawn_value
  let black_knights =
    { board.bitboard(board, piece.Knight, color.Black) |> bitboard.popcount }
    * knight_value
  let black_bishops =
    { board.bitboard(board, piece.Bishop, color.Black) |> bitboard.popcount }
    * bishop_value
  let black_rooks =
    { board.bitboard(board, piece.Rook, color.Black) |> bitboard.popcount }
    * rook_value
  let black_queens =
    { board.bitboard(board, piece.Queen, color.Black) |> bitboard.popcount }
    * queen_value

  let white_material =
    white_pawns + white_knights + white_bishops + white_rooks + white_queens
  let black_material =
    black_pawns + black_knights + black_bishops + black_rooks + black_queens

  { white_material - black_material } * { board.color |> color.sign }
}

pub fn evaluate(board: board.Board) -> Int {
  count_material(board)
}
