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
  post_white_kingside.castling_rights |> should.equal(0b1100)

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
  post_white_queenside.castling_rights |> should.equal(0b1100)
}

pub fn en_passant_white_test() {
  let board = board.from_fen("4k3/2p5/8/3P4/4p3/8/5P2/4K3 w - -")
  let board =
    board |> board.make_move(move.new(square.F2, square.F4, flags.double_move))
  let board =
    board |> board.make_move(move.new(square.E4, square.F3, flags.en_passant))

  board |> board.piece_bitboard(piece.Pawn) |> should.equal(0x4000800200000)
  board |> board.color_bitboard(color.White) |> should.equal(0x800000010)
  board |> board.color_bitboard(color.Black) |> should.equal(0x1004000000200000)
}

pub fn en_passant_black_test() {
  let board = board.from_fen("4k3/2p5/8/3P4/4p3/8/5P2/4K3 b - -")
  let board =
    board |> board.make_move(move.new(square.C7, square.C5, flags.double_move))
  let board =
    board |> board.make_move(move.new(square.D5, square.C6, flags.en_passant))

  board |> board.piece_bitboard(piece.Pawn) |> should.equal(0x40010002000)
  board |> board.color_bitboard(color.White) |> should.equal(0x40000002010)
  board |> board.color_bitboard(color.Black) |> should.equal(0x1000000010000000)
}

pub fn double_move_ep_square_test() {
  let board = board.from_fen("4k3/2p5/8/3P4/4p3/8/5P2/4K3 w - -")

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

pub fn capture_test() {
  let board =
    board.from_fen(
      "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -",
    )
    |> board.make_move(move.new(square.E5, square.F7, flags.capture))

  board |> board.piece_bitboard(piece.Knight) |> should.equal(0x20220000040000)
  board |> board.piece_bitboard(piece.Pawn) |> should.equal(0xd50081280e700)
  board |> board.color_bitboard(color.White) |> should.equal(0x2000081024ff91)
  board |> board.color_bitboard(color.Black) |> should.equal(0x915d730002800000)
}

pub fn king_move_test() {
  let board =
    board.from_fen(
      "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -",
    )
    |> board.make_move(move.new(square.E1, square.D1, 0))

  board |> board.piece_bitboard(piece.King) |> should.equal(0x1000000000000008)
  board |> board.color_bitboard(color.White) |> should.equal(0x181024ff89)
  board |> board.color_bitboard(color.Black) |> should.equal(0x917d730002800000)
  board.castling_rights |> should.equal(0b1100)
}

pub fn rook_move_test() {
  let board =
    board.from_fen(
      "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -",
    )
    |> board.make_move(move.new(square.H1, square.F1, 0))

  board |> board.piece_bitboard(piece.Rook) |> should.equal(0x8100000000000021)
  board |> board.color_bitboard(color.White) |> should.equal(0x181024ff31)
  board |> board.color_bitboard(color.Black) |> should.equal(0x917d730002800000)
  board.castling_rights |> should.equal(0b1110)
}

// oh GOD FUCKING DAMMIT OF COURSE LUC YOU IDIOT
pub fn rook_capture_rook_test() {
  let board =
    board.from_fen("r3k3/8/8/8/8/8/7r/R3K2R b KQq -")
    |> board.make_move(move.new(square.H2, square.H1, flags.capture))

  board.piece_bitboard(board, piece.Rook) |> should.equal(0x100000000000081)
  board.color_bitboard(board, color.White) |> should.equal(0x11)
  board.color_bitboard(board, color.Black) |> should.equal(0x1100000000000080)
}
