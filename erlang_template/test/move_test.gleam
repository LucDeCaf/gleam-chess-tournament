import erlang_template/chess/board/move
import erlang_template/chess/board/square
import gleam/list
import gleeunit/should

pub fn new_test() {
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
