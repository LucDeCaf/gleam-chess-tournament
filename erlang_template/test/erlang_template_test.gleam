import erlang_template/chess/board
import erlang_template/chess/board/bitboard
import erlang_template/chess/board/color
import erlang_template/chess/board/flags
import erlang_template/chess/board/move
import erlang_template/chess/board/piece
import erlang_template/chess/board/square
import erlang_template/chess/fen
import erlang_template/chess/move_gen
import erlang_template/chess/move_gen/move_tables
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// Custom fen with many pawn captures / moves
const pawn_test_fen = "rnbqkb1r/p1p1pppp/8/2PpP3/8/1p3P1n/PP1P2PP/RNBQKBNR w KQkq - 0 1"

pub fn bitboard_pop_lsb_test() {
  bitboard.pop_lsb(0b00101100)
  |> should.equal(0b00101000)

  bitboard.pop_lsb(0b1)
  |> should.equal(0)

  bitboard.pop_lsb(0)
  |> should.equal(0)

  bitboard.pop_lsb(0b1111001001011)
  |> should.equal(0b1111001001010)
}

pub fn bitboard_lsb_index_test() {
  bitboard.lsb_index(0b11111000)
  |> should.equal(3)

  bitboard.lsb_index(0b10011010)
  |> should.equal(1)

  bitboard.lsb_index(0b1)
  |> should.equal(0)

  bitboard.lsb_index(0)
  |> should.equal(-1)

  bitboard.lsb_index(0b100000000000000000000000000000)
  |> should.equal(29)
}

pub fn bitboard_map_index_test() {
  let indexes = bitboard.map_index(0b11010101, fn(i) { i })
  let expected = [0, 2, 4, 6, 7]
  indexes
  |> list.zip(expected)
  |> list.each(fn(testcase) { testcase.0 |> should.equal(testcase.1) })

  let indexes = bitboard.map_index(0b1000010, fn(i) { i })
  let expected = [1, 6]
  indexes
  |> list.zip(expected)
  |> list.each(fn(testcase) { testcase.0 |> should.equal(testcase.1) })
}

pub fn move_new_test() {
  let squares = [
    #(square.A1, square.C6),
    #(square.B1, square.H1),
    #(square.H2, square.B6),
    #(square.A1, square.H8),
    #(square.H1, square.A8),
    #(square.A8, square.H8),
    #(square.H8, square.A8),
  ]

  use testcase <- list.each(squares)
  testcase
  |> fn(testcase) { move.new(testcase.0, testcase.1, 0) }
  |> fn(move) { #(move.source(move), move.target(move)) }
  |> should.equal(testcase)
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

pub fn move_gen_sliding_targets_test() {
  let rook_shifts = [-1, 1, -8, 8]
  let bishop_shifts = [-7, 7, -9, 9]

  let blockers = 9_304_438_067_099_336_704
  let square = square.from_index_unchecked(45)

  let expected_bishop_moves = 22_518_341_868_716_032
  let expected_rook_moves = 9_110_690_786_705_408

  move_tables.sliding_targets(square, blockers, rook_shifts)
  |> should.equal(expected_rook_moves)
  move_tables.sliding_targets(square, blockers, bishop_shifts)
  |> should.equal(expected_bishop_moves)

  let square = square.A1
  let expected_rook_moves = 1_103_823_438_206
  move_tables.sliding_targets(square, blockers, rook_shifts)
  |> should.equal(expected_rook_moves)
}

pub fn move_gen_bishop_targets_test() {
  let move_tables = move_tables.new()
  let blockers = 9_304_438_067_099_336_704
  let square = square.from_index_unchecked(45)

  let expected_bishop_moves = 22_518_341_868_716_032
  let expected_rook_moves = 9_110_690_786_705_408

  move_tables.bishop_targets(square, blockers, move_tables)
  |> should.equal(expected_bishop_moves)
  move_tables.rook_targets(square, blockers, move_tables)
  |> should.equal(expected_rook_moves)
}

pub fn move_tables_en_passant_source_mask_test() {
  let move_tables = move_tables.new()
  move_tables.en_passant_source_masks(square.E3, color.Black, move_tables)
  |> should.equal(0x28000000)
  move_tables.en_passant_source_masks(square.D6, color.White, move_tables)
  |> should.equal(0x1400000000)
  move_tables.en_passant_source_masks(square.H6, color.White, move_tables)
  |> should.equal(0x4000000000)
  move_tables.en_passant_source_masks(square.H6, color.Black, move_tables)
  |> should.equal(0x40000000000000)
}

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

pub fn flags_new_test() {
  flags.new(None, False, 0) |> should.equal(0b0000)
  flags.new(None, True, 0) |> should.equal(0b0100)
  flags.new(Some(piece.Knight), True, 0) |> should.equal(0b1100)
  flags.new(Some(piece.Bishop), True, 0) |> should.equal(0b1101)
  flags.new(Some(piece.Rook), True, 0) |> should.equal(0b1110)
  flags.new(Some(piece.Queen), True, 0) |> should.equal(0b1111)
  flags.new(Some(piece.Knight), False, 0) |> should.equal(0b1000)
  flags.new(Some(piece.Bishop), False, 0) |> should.equal(0b1001)
  flags.new(Some(piece.Rook), False, 0) |> should.equal(0b1010)
  flags.new(Some(piece.Queen), False, 0) |> should.equal(0b1011)
}
// TODO: More exhaustive double pawn move tests
