import erlang_template/chess/board
import erlang_template/chess/board/color
import erlang_template/chess/board/move
import erlang_template/chess/eval
import erlang_template/chess/move_gen
import erlang_template/chess/move_gen/move_tables
import gleam/bool
import gleam/int
import gleam/io
import gleam/list

// TODO: Tests
fn search(board, depth, tables) {
  search_inner(board, depth, -2_147_483_648, 2_147_483_647, tables)
}

fn search_inner(
  board: board.Board,
  depth: Int,
  alpha,
  beta,
  tables: move_tables.MoveTables,
) {
  // Max depth
  // TODO: Quiescence search
  use <- bool.lazy_guard(when: depth == 0, return: fn() { eval.evaluate(board) })

  let moves = board |> move_gen.legal_moves(tables)

  // Stalemate or checkmate
  use <- bool.lazy_guard(when: list.is_empty(moves), return: fn() {
    case
      move_gen.square_attacked_by(
        board,
        board.king_square(board, board.color),
        board.color |> color.inverse,
        tables,
      )
    {
      True -> -1_000_000 * { board.color |> color.sign }
      False -> 0
    }
  })

  // Might be alpha-beta pruning, I FUCKING hope I don't have to touch this again lmao
  let best_result =
    list.fold_until(moves, #(-2_147_483_648, alpha), fn(best_result, move) {
      let alpha = best_result.1

      let board = board.make_move(board, move)
      let score = -search_inner(board, depth - 1, -beta, -alpha, tables)

      let best_result = case score > best_result.0 {
        True -> {
          let best_value = alpha
          let alpha = int.max(alpha, score)
          #(best_value, alpha)
        }
        False -> best_result
      }

      case score >= beta {
        True -> {
          io.debug("failsoft")
          list.Stop(best_result)
        }
        False -> list.Continue(best_result)
      }
    })

  best_result.0
}

pub fn best_move(board, depth, tables) -> #(move.Move, Int) {
  use <- bool.guard(when: depth == 0, return: #(0, 0))

  let moves = move_gen.legal_moves(board, tables)
  let move_results =
    moves
    |> list.map(fn(move) {
      let board = board.make_move(board, move)
      let eval = search(board, depth - 1, tables)
      #(move, eval)
    })
    |> list.sort(fn(a, b) { int.compare(a.1, b.1) })

  case list.first(move_results) {
    Ok(move_result) -> move_result
    Error(_) -> #(0, 0)
  }
}
