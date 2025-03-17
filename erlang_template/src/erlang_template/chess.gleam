import erlang_template/chess/board
import erlang_template/chess/color
import erlang_template/chess/fen
import erlang_template/chess/move
import erlang_template/chess/move_gen
import erlang_template/chess/move_tables
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
) -> Result(String, String) {
  let move_tables = move_tables.new_move_tables()
  let board =
    board.Board(pieces: fen.pieces(fen), color: turn, castling_rights: 0b1111)

  let moves = move_gen.legal_moves(board, move_tables)

  // TODO: Move evaluation

  let assert Ok(first) = moves |> list.first

  Ok(move.to_string(first))
}
