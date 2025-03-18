import erlang_template/chess
import erlang_template/chess/move_gen/move_tables
import erlang_template/context
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/json
import mist
import perft
import wisp.{type Request, type Response}
import wisp/wisp_mist

pub fn main() {
  // engine_main()

  // TODO: Refactor into http://localhost:8000/perft?depth=n
  perft.run(2)
}

fn engine_main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let ctx = context.Context(move_tables: move_tables.new())

  let handler = fn(req: Request) { handle_request(req, ctx) }

  let assert Ok(_) =
    handler
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(8000)
    |> mist.start_http

  process.sleep_forever()
}

fn handle_request(request: Request, ctx: context.Context) -> Response {
  case wisp.path_segments(request) {
    ["move"] -> handle_move(request, ctx)
    _ -> wisp.ok()
  }
}

fn move_decoder() {
  use fen <- decode.field("fen", decode.string)
  use turn <- decode.field("turn", chess.player_decoder())
  use failed_moves <- decode.field("failed_moves", decode.list(decode.string))
  decode.success(#(fen, turn, failed_moves))
}

fn handle_move(request: Request, ctx: context.Context) -> Response {
  use body <- wisp.require_string_body(request)
  let decode_result = json.parse(body, move_decoder())
  case decode_result {
    Error(_) -> wisp.bad_request()
    Ok(move) -> {
      let move_result = chess.move(move.0, move.1, ctx, move.2)
      case move_result {
        Ok(move) -> wisp.ok() |> wisp.string_body(move)
        Error(reason) ->
          wisp.internal_server_error() |> wisp.string_body(reason)
      }
    }
  }
}
