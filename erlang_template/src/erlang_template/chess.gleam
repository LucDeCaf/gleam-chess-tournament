import erlang_template/chess/board
import erlang_template/chess/board/color
import erlang_template/chess/board/move
import erlang_template/chess/fen
import erlang_template/chess/move_gen
import erlang_template/chess/move_gen/move_tables
import erlang_template/context
import gleam/dynamic/decode
import gleam/list

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
  turn: color.Color,
  failed_moves: List(String),
  ctx: context.Context,
) -> Result(String, String) {
  let board =
    board.Board(
      pieces: fen.pieces(fen),
      color: turn,
      castling_rights: 0b1111,
      en_passant: fen.en_passant(fen),
    )

  let moves = move_gen.legal_moves(board, ctx.move_tables)

  // TODO: Move evaluation

  let assert Ok(first) = moves |> list.first

  Ok(move.to_string(first))
}
