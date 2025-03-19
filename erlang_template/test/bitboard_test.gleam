import erlang_template/chess/board/bitboard
import gleam/list
import gleeunit/should

pub fn pop_lsb_test() {
  bitboard.pop_lsb(0b00101100)
  |> should.equal(0b00101000)

  bitboard.pop_lsb(0b1)
  |> should.equal(0)

  bitboard.pop_lsb(0)
  |> should.equal(0)

  bitboard.pop_lsb(0b1111001001011)
  |> should.equal(0b1111001001010)
}

pub fn lsb_index_test() {
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

pub fn map_index_test() {
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
