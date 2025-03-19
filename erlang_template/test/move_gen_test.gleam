import erlang_template/chess/board
import erlang_template/chess/board/color
import erlang_template/chess/board/flags
import erlang_template/chess/board/move
import erlang_template/chess/board/square
import erlang_template/chess/fen
import erlang_template/chess/move_gen
import erlang_template/chess/move_gen/move_tables
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleeunit/should

pub fn move_gen_pawn_moves_test() {
  let board =
    board.Board(
      pieces: fen.pieces(fen.starting_fen),
      color: color.White,
      castling_rights: 0b1111,
      en_passant: None,
    )
  let moves = move_gen.pawn_straight_moves(board) |> list.sort(int.compare)
  let expected_moves =
    [
      move.new(square.A2, square.A3, 0),
      move.new(square.A2, square.A4, flags.double_move),
      move.new(square.B2, square.B3, 0),
      move.new(square.B2, square.B4, flags.double_move),
      move.new(square.C2, square.C3, 0),
      move.new(square.C2, square.C4, flags.double_move),
      move.new(square.D2, square.D3, 0),
      move.new(square.D2, square.D4, flags.double_move),
      move.new(square.E2, square.E3, 0),
      move.new(square.E2, square.E4, flags.double_move),
      move.new(square.F2, square.F3, 0),
      move.new(square.F2, square.F4, flags.double_move),
      move.new(square.G2, square.G3, 0),
      move.new(square.G2, square.G4, flags.double_move),
      move.new(square.H2, square.H3, 0),
      move.new(square.H2, square.H4, flags.double_move),
    ]
    |> list.sort(int.compare)

  use testcase <- list.each(list.zip(moves, expected_moves))
  // io.debug(
  //   "expected "
  //   <> move.to_debug_string(testcase.1)
  //   <> ", got "
  //   <> move.to_debug_string(testcase.0),
  // )
  testcase.0 |> should.equal(testcase.1)
}

pub fn move_gen_pawn_captures_test() {
  // Custom fen with many pawn captures / moves
  let pawn_test_fen =
    "rnbqkb1r/p1p1pppp/8/2PpP3/8/1p3P1n/PP1P2PP/RNBQKBNR w KQkq - 0 1"

  let board =
    board.Board(
      pieces: fen.pieces(pawn_test_fen),
      color: color.White,
      castling_rights: 0b1111,
      en_passant: Some(square.D6),
    )
  let move_tables = move_tables.new()

  let moves =
    move_gen.pawn_captures(board, move_tables) |> list.sort(int.compare)
  let expected_moves =
    [
      move.new(square.C5, square.D6, flags.new(None, True, flags.en_passant)),
      move.new(square.E5, square.D6, flags.new(None, True, flags.en_passant)),
      move.new(square.E5, square.F6, flags.capture),
      move.new(square.A2, square.B3, flags.capture),
      move.new(square.G2, square.H3, flags.capture),
    ]
    |> list.sort(int.compare)

  let white_testcases = list.zip(moves, expected_moves)

  // Update EP square and test with black pawns
  let board =
    board.Board(
      pieces: fen.pieces(pawn_test_fen),
      color: color.Black,
      castling_rights: 0b1111,
      en_passant: Some(square.E4),
    )

  let moves =
    move_gen.pawn_captures(board, move_tables) |> list.sort(int.compare)
  let expected_moves =
    [
      move.new(square.A7, square.B6, flags.capture),
      move.new(square.C7, square.B6, flags.capture),
      move.new(square.B3, square.A2, flags.capture),
      move.new(square.D5, square.E4, flags.new(None, True, flags.en_passant)),
      move.new(square.F6, square.E5, flags.capture),
    ]
    |> list.sort(int.compare)

  let black_testcases = list.zip(moves, expected_moves)

  use testcase <- list.each(list.append(white_testcases, black_testcases))
  // io.debug(
  //   "expected "
  //   <> move.to_debug_string(testcase.1)
  //   <> ", got "
  //   <> move.to_debug_string(testcase.0),
  // )
  testcase.0 |> should.equal(testcase.1)
}

pub fn move_gen_sliding_targets_test() {
  let blockers = 0x8120012000140000
  let square = square.F6

  let expected_bishop_moves = 0x8850005088040000
  let expected_rook_moves = 0x20df2000000000

  move_tables.sliding_targets(square, blockers, move_tables.rook_move_shifts)
  |> should.equal(expected_rook_moves)
  move_tables.sliding_targets(square, blockers, move_tables.bishop_move_shifts)
  |> should.equal(expected_bishop_moves)

  let square = square.A1
  let expected_rook_moves = 0x101010101fe
  move_tables.sliding_targets(square, blockers, move_tables.rook_move_shifts)
  |> should.equal(expected_rook_moves)
}

pub fn move_gen_knight_moves_test() {
  let move_tables = move_tables.new()
  let board =
    board.Board(
      pieces: fen.pieces(fen.starting_fen),
      color: color.White,
      castling_rights: 0b1111,
      en_passant: None,
    )

  let moves =
    move_gen.knight_moves(board, move_tables) |> list.sort(int.compare)
  let expected =
    [
      move.new(square.B1, square.A3, 0),
      move.new(square.B1, square.C3, 0),
      move.new(square.G1, square.H3, 0),
      move.new(square.G1, square.F3, 0),
    ]
    |> list.sort(int.compare)

  moves
  |> list.zip(expected)
  |> list.each(fn(testcase) { testcase.0 |> should.equal(testcase.1) })
}
