import erlang_template/chess/board
import erlang_template/chess/board/color
import erlang_template/chess/board/move
import erlang_template/chess/engine/search
import erlang_template/context
import gleam/dynamic/decode

pub fn player_decoder() {
  use player_string <- decode.then(decode.string)
  case player_string {
    "white" -> decode.success(color.White)
    "black" -> decode.success(color.Black)
    _ -> decode.failure(color.White, "Invalid player")
  }
}

pub fn move(
  fen: String,
  turn _turn: color.Color,
  ctx ctx: context.Context,
  failed_moves _failed_moves: List(String),
) -> Result(String, String) {
  let board = board.from_fen(fen)

  let max_depth = 4
  let chosen_move = search.best_move(board, max_depth, ctx.move_tables)

  Ok(move.to_string(chosen_move))
}
