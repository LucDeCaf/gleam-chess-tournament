import erlang_template/chess/bitboard
import erlang_template/chess/board
import erlang_template/chess/color
import erlang_template/chess/fen
import erlang_template/chess/move
import erlang_template/chess/move_gen
import erlang_template/chess/move_tables
import erlang_template/chess/square
import gleam/int
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

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
  |> fn(testcase) { move.new(testcase.0, testcase.1) }
  |> fn(move) { #(move.source(move), move.target(move)) }
  |> should.equal(testcase)
}

pub fn move_gen_knight_moves_test() {
  let move_tables = move_tables.new_move_tables()
  let board =
    board.Board(
      pieces: fen.pieces(fen.starting_fen),
      color: color.White,
      castling_rights: 0b1111,
    )

  let moves =
    move_gen.knight_moves(board, move_tables) |> list.sort(int.compare)
  let expected =
    [
      move.new(square.B1, square.A3),
      move.new(square.B1, square.C3),
      move.new(square.G1, square.H3),
      move.new(square.G1, square.F3),
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
  // let square = square.A1
  // let expected_rook_moves = 1103823438206 
  // move_gen.sliding_targets(square, blockers, rook_shifts)
  // |> should.equal(expected_rook_moves)
}
