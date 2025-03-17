import erlang_template/chess/bitboard
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
