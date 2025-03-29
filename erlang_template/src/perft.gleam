import erlang_template/chess/board
import erlang_template/chess/board/move
import erlang_template/chess/move_gen
import erlang_template/chess/tables/move_tables
import gleam/dict
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

pub fn divide(board: board.Board, depth: Int, tables: move_tables.MoveTables) {
  let moves = move_gen.legal_moves(board, tables)
  moves
  |> list.map(fn(move) {
    let board = board |> board.make_move(move)
    let count = perft(board, depth - 1, tables)

    #(move |> move.to_string, count)
  })
  |> dict.from_list
}
