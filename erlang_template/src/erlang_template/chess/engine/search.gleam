import erlang_template/chess/board
import erlang_template/chess/board/color
import erlang_template/chess/board/move
import erlang_template/chess/engine/eval
import erlang_template/chess/move_gen
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/order

pub fn best_move(board, depth, mt, pst) {
  use <- bool.guard(depth == 0, 0)

  let moves = board |> move_gen.legal_moves(mt)

  let evals =
    moves
    |> list.map(fn(move) {
      let board = board |> board.make_move(move)
      #(move, search(board, depth - 1, mt, pst))
    })
    |> list.sort(fn(a, b) { int.compare(a.1, b.1) })

  case list.first(evals) {
    Ok(eval) -> eval.0
    Error(_) -> 0
  }
}

pub fn search(board, depth, mt, pst) {
  search_inner(board, depth, -999_999_999, 999_999_999, mt, pst)
}

pub fn search_inner(board, depth, alpha, beta, mt, pst) -> Int {
  // use <- bool.lazy_guard(depth == 0, fn() {
  //   quiesce(board, alpha, beta, tables)
  // })
  use <- bool.lazy_guard(depth == 0, fn() { eval.evaluate(board, pst) })

  let moves = board |> move_gen.legal_moves(mt) |> list.sort(heuristics)

  use <- bool.lazy_guard(list.is_empty(moves), fn() {
    io.debug("terminal position found")
    case
      move_gen.square_attacked_by(
        board,
        board.king_square(board, board.color),
        board.color |> color.inverse,
        mt,
      )
    {
      // Checkmate
      True -> -999_999_999
      // Stalemate
      False -> 0
    }
  })

  list.fold_until(moves, alpha, fn(alpha, move) {
    let board = board.make_move(board, move)
    let score = -search_inner(board, depth - 1, -beta, -alpha, mt, pst)

    let alpha = int.max(alpha, score)

    case score >= beta {
      True -> io.debug(list.Stop(alpha))
      False -> list.Continue(alpha)
    }
  })
}

pub fn quiesce(board, alpha, beta, mt, pst) -> Int {
  let stand_pat = eval.evaluate(board, pst)

  use <- bool.guard(stand_pat >= beta, stand_pat)

  let alpha = int.max(alpha, stand_pat)

  let captures =
    board
    |> move_gen.legal_moves(mt)
    |> list.filter(move.is_capture)
    |> list.sort(heuristics)

  io.debug("captures: " <> int.to_string(list.length(captures)))

  list.fold_until(captures, alpha, fn(alpha, move) {
    let board = board.make_move(board, move)
    let score = -quiesce(board, -beta, -alpha, mt, pst)

    let alpha = int.max(alpha, score)

    case alpha >= beta {
      True -> list.Stop(alpha)
      False -> list.Continue(alpha)
    }
  })
}

pub fn heuristics(a, b) -> order.Order {
  // MSB(1) is capture, MSB(2) is promotion, MSB(3,4) are special moves roughly in order
  let a_flags = move.flags(a)
  let b_flags = move.flags(b)
  int.compare(a_flags, b_flags)
}
