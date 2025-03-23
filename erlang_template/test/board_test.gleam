import erlang_template/chess/board
import erlang_template/chess/board/color
import erlang_template/chess/board/flags
import erlang_template/chess/board/move
import erlang_template/chess/board/piece
import erlang_template/chess/board/square
import gleam/option.{Some}
import gleeunit/should

pub fn castle_test() {
  // Kiwipete
  let board =
    board.from_fen(
      "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -",
    )

  let post_white_kingside =
    board
    |> board.make_move(move.new(square.E1, square.G1, flags.castle_kingside))

  post_white_kingside
  |> board.color_bitboard(color.White)
  |> should.equal(0x181024ff61)
  post_white_kingside
  |> board.piece_bitboard(piece.Rook)
  |> should.equal(0x8100000000000021)
  post_white_kingside
  |> board.piece_bitboard(piece.King)
  |> should.equal(0x1000000000000040)

  let post_white_queenside =
    board
    |> board.make_move(move.new(square.E1, square.C1, flags.castle_queenside))

  post_white_queenside
  |> board.color_bitboard(color.White)
  |> should.equal(0x181024ff8c)
  post_white_queenside
  |> board.piece_bitboard(piece.Rook)
  |> should.equal(0x8100000000000088)
  post_white_queenside
  |> board.piece_bitboard(piece.King)
  |> should.equal(0x1000000000000004)
}

pub fn double_move_ep_square_test() {
  let board = board.from_fen("4k3/2p5/8/3P4/4p3/8/5P2/4K3 w - - 0 1")

  let board =
    board
    |> board.make_move(move.new(square.F2, square.F4, flags.double_move))
  board.en_passant
  |> should.equal(Some(square.F3))

  let board =
    board |> board.make_move(move.new(square.C7, square.C5, flags.double_move))
  board.en_passant
  |> should.equal(Some(square.C6))
}
