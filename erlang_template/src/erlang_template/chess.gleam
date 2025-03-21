import erlang_template/chess/board
import erlang_template/chess/board/color
import erlang_template/chess/board/move
import erlang_template/chess/move_gen
import erlang_template/context
import gleam/dynamic/decode
import gleam/list
import gleam/result

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

  let moves = move_gen.legal_moves(board, ctx.move_tables)

  // TODO: Move evaluation

  let chosen_move = moves |> list.first |> result.unwrap(0)

  Ok(move.to_string(chosen_move))
}
