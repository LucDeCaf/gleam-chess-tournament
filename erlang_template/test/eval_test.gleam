import erlang_template/chess/board
import erlang_template/chess/eval
import erlang_template/chess/fen
import gleeunit/should

pub fn material_balance_test() {
  // Position has +1 white rook
  let board = board.from_fen("4k3/2b1n3/1n3PPP/8/ppp5/2N5/4BN2/4K2R w - - 0 1")
  eval.material_balance(board) |> should.equal(eval.rook_value)

  let board = board.from_fen("4k3/2b1n3/1n3PPP/8/ppp5/2N5/4BN2/4K2R b - - 0 1")
  eval.material_balance(board) |> should.equal(-eval.rook_value)

  let board = board.from_fen(fen.starting_fen)
  eval.material_balance(board) |> should.equal(0)
}
