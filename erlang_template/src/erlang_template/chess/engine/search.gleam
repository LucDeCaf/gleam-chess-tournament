import erlang_template/chess/board
import erlang_template/chess/board/move
import erlang_template/chess/board/piece
import erlang_template/chess/engine/eval
import erlang_template/chess/move_gen
import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/order

pub fn best_move(board, depth, mt, pst) {
  // Panic on depth <= 0
  use <- bool.lazy_guard(depth <= 0, fn() {
    panic as "search.best_move called with depth <= 0"
  })

  let search_depth = depth - 1

  let search_result =
    board
    |> move_gen.legal_moves(mt)
    |> list.sort(heuristics)
    |> list.fold(#(0, -999_999_999, 0), fn(acc, move) {
      let #(best_move, best_score, node_count) = acc
      let #(score, node_count) =
        board
        |> board.make_move(move)
        |> search(search_depth, -999_999_999, 999_999_999, mt, pst, node_count)
      let score = -score

      let best_move = case score > best_score {
        True -> move
        False -> best_move
      }

      let best_score = int.max(score, best_score)

      io.debug(move.to_string(move) <> ": " <> int.to_string(score))
      io.debug("best score: " <> int.to_string(best_score))

      #(best_move, best_score, node_count)
    })

  io.debug("--- SEARCH COMPLETE ---")
  io.debug(
    "best move:       "
    <> move.to_string(search_result.0)
    <> " (0x"
    <> int.to_base16(search_result.0)
    <> ")",
  )
  io.debug("score:           " <> int.to_string(search_result.1))
  io.debug("nodes evaluated: " <> int.to_string(search_result.2))

  search_result.0
}

pub fn search(
  board,
  depth,
  alpha,
  beta,
  mt,
  pst,
  nodes_evaluated,
) -> #(Int, Int) {
  use <- bool.lazy_guard(depth == 0, fn() {
    quiesce(board, 5, alpha, beta, mt, pst, nodes_evaluated)
  })
  // use <- bool.lazy_guard(depth == 0, fn() { eval.evaluate(board, pst) })

  let moves = board |> move_gen.legal_moves(mt) |> list.sort(heuristics)

  use <- bool.lazy_guard(list.is_empty(moves), fn() {
    io.debug("terminal position found")
    case move_gen.is_check(board, mt) {
      // Checkmate
      True -> #(-999_999_999, nodes_evaluated)
      // Stalemate
      False -> #(0, nodes_evaluated)
    }
  })

  list.fold_until(moves, #(alpha, nodes_evaluated), fn(result, move) {
    let alpha = result.0
    let nodes_evaluated = result.1

    let board = board.make_move(board, move)
    let #(score, nodes_evaluated) =
      search(board, depth - 1, -beta, -alpha, mt, pst, nodes_evaluated)
    let score = -score

    let alpha = int.max(alpha, score)

    let result = #(alpha, nodes_evaluated)

    case score >= beta {
      True -> list.Stop(result)
      False -> list.Continue(result)
    }
  })
}

// TODO: Capture ordering (least valuable to most valuable)
pub fn quiesce(
  board,
  max_depth,
  alpha,
  beta,
  mt,
  pst,
  nodes_evaluated,
) -> #(Int, Int) {
  let stand_pat = eval.evaluate(board, pst)

  use <- bool.guard(stand_pat >= beta || max_depth == 0, #(
    stand_pat,
    nodes_evaluated + 1,
  ))

  let alpha = int.max(alpha, stand_pat)

  let moves =
    board
    |> move_gen.legal_moves(mt)
    |> list.sort(fn(a, b) {
      // Sort so that least valuable pieces capture first (cause more beta-cutoffs)
      let assert Some(a_piece) = board.piece_at(board, move.source(a))
      let assert Some(b_piece) = board.piece_at(board, move.source(b))
      int.compare(piece.index(a_piece), piece.index(b_piece))
    })
  let captures =
    moves
    |> list.filter(move.is_capture)

  let moves_to_search = case
    list.is_empty(captures) && move_gen.is_check(board, mt)
  {
    // No captures resolve the check - search all moves instead
    True -> moves
    // Otherwise search captures as normal
    False -> captures
  }

  use #(alpha, nodes_evaluated), move <- list.fold_until(moves_to_search, #(
    alpha,
    nodes_evaluated,
  ))
  let board = board.make_move(board, move)
  let #(score, nodes_evaluated) =
    quiesce(board, max_depth - 1, -beta, -alpha, mt, pst, nodes_evaluated)
  let score = -score

  let alpha = int.max(alpha, score)

  let result = #(alpha, nodes_evaluated)

  case alpha >= beta {
    True -> list.Stop(result)
    False -> list.Continue(result)
  }
}

pub fn heuristics(a, b) -> order.Order {
  // MSB(1) is capture, MSB(2) is promotion, MSB(3,4) are special moves roughly in order
  // Therefore sorting flags is a passable heuristic for now
  let a_flags = move.flags(a)
  let b_flags = move.flags(b)
  int.compare(b_flags, a_flags)
}
