import erlang_template/chess/board/flags
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

pub fn is_capture_test() {
  let moves = [
    move.new(square.A1, square.A1, flags.capture),
    move.new(square.A2, square.A1, 0),
    move.new(square.A3, square.A1, flags.capture),
    move.new(square.A4, square.A1, flags.capture),
    move.new(square.A5, square.A1, 0),
    move.new(square.A6, square.A1, 0),
    move.new(square.A7, square.A1, flags.capture),
    move.new(square.A8, square.A1, 0),
    move.new(square.B1, square.A1, 0),
    move.new(square.B2, square.A1, flags.capture),
    move.new(square.B3, square.A1, 0),
  ]

  let captures = list.filter(moves, move.is_capture)
  let not_captures = list.filter(moves, fn(move) { !move.is_capture(move) })

  { list.length(captures) + list.length(not_captures) }
  |> should.equal(list.length(moves))

  use capture <- list.each(captures)
  move.flags(capture) |> should.equal(flags.capture)

  use not_capture <- list.each(not_captures)
  move.flags(not_capture) |> should.equal(0)
}
