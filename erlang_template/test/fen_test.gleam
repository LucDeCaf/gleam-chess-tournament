import erlang_template/chess/board
import erlang_template/chess/board/color
import erlang_template/chess/board/piece
import gleam/list
import gleeunit/should

pub fn kiwipete_fen_test() {
  let kiwipete_fen =
    "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -"
  let board = board.from_fen(kiwipete_fen)

  let expected_pawns = 0x2d50081280e700
  let expected_knights = 0x221000040000
  let expected_bishops = 0x40010000001800
  let expected_rooks = 0x8100000000000081
  let expected_queens = 0x10000000200000
  let expected_kings = 0x1000000000000010
  let expected_white = 0x181024ff91
  let expected_black = 0x917d730002800000

  let pawns = board |> board.piece_bitboard(piece.Pawn)
  let knights = board |> board.piece_bitboard(piece.Knight)
  let bishops = board |> board.piece_bitboard(piece.Bishop)
  let rooks = board |> board.piece_bitboard(piece.Rook)
  let queens = board |> board.piece_bitboard(piece.Queen)
  let kings = board |> board.piece_bitboard(piece.King)
  let white = board |> board.color_bitboard(color.White)
  let black = board |> board.color_bitboard(color.Black)

  let expected = [
    expected_pawns,
    expected_knights,
    expected_bishops,
    expected_rooks,
    expected_queens,
    expected_kings,
    expected_white,
    expected_black,
  ]
  let generated = [pawns, knights, bishops, rooks, queens, kings, white, black]
  let test_cases = list.zip(expected, generated)

  use test_case <- list.each(test_cases)
  test_case.0 |> should.equal(test_case.1)
}
