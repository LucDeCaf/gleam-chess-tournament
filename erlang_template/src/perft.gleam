import erlang_template/chess/board
import erlang_template/chess/fen
import erlang_template/chess/move_gen
import erlang_template/chess/move_gen/move_tables
import gleam/int
import gleam/list

pub fn perft(
  board: board.Board,
  depth: Int,
  tables: move_tables.MoveTables,
) -> Int {
  let moves = move_gen.legal_moves(board, tables)
  let move_count = list.length(moves)
  case depth {
    // Base cases
    0 -> 1
    1 -> move_count
    // Body
    _ -> {
      let subposition_move_count =
        moves
        |> list.map(fn(move) {
          let new_board = board |> board.make_move(move)
          let new_count = perft(new_board, depth - 1, tables)
          new_count
        })
        |> list.fold(0, int.add)

      subposition_move_count
    }
  }
}
