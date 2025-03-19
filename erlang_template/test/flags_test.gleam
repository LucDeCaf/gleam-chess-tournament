import erlang_template/chess/board/flags
import erlang_template/chess/board/piece
import gleam/option.{None, Some}
import gleeunit/should

pub fn new_test() {
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
