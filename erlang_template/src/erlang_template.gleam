import erlang_template/chess
import erlang_template/chess/board
import erlang_template/chess/engine/eval
import erlang_template/chess/tables/move_tables
import erlang_template/chess/tables/piece_square_tables
import erlang_template/context
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/int
import gleam/json
import mist
import perft
import wisp.{type Request, type Response}
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let ctx =
    context.Context(
      move_tables: move_tables.new(),
      piece_square_tables: piece_square_tables.new(),
    )

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
    ["perft"] -> handle_perft(request, ctx)
    ["divide"] -> handle_divide(request, ctx)
    ["eval"] -> handle_eval(request, ctx)
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

fn perft_decoder() {
  use fen <- decode.field("fen", decode.string)
  use depth <- decode.field("depth", decode.int)
  decode.success(#(fen, depth))
}

fn handle_perft(request: Request, ctx: context.Context) -> Response {
  use body <- wisp.require_string_body(request)
  let decode_result = json.parse(body, perft_decoder())
  case decode_result {
    Error(_) -> wisp.bad_request()
    Ok(#(fen, depth)) -> {
      let board = board.from_fen(fen)
      let perft_result = perft.perft(board, depth, ctx.move_tables)
      wisp.ok() |> wisp.string_body(int.to_string(perft_result))
    }
  }
}

fn handle_divide(request: Request, ctx: context.Context) {
  use body <- wisp.require_string_body(request)
  let decode_result = json.parse(body, perft_decoder())
  case decode_result {
    Error(_) -> wisp.bad_request()
    Ok(#(fen, depth)) -> {
      let board = board.from_fen(fen)
      let divide_result = perft.divide(board, depth, ctx.move_tables)
      let json =
        divide_result
        |> json.dict(fn(str) { str }, json.int)
        |> json.to_string_tree

      wisp.json_response(json, 200)
    }
  }
}

fn eval_decoder() {
  use fen <- decode.field("fen", decode.string)
  decode.success(fen)
}

fn handle_eval(request: Request, ctx: context.Context) {
  use body <- wisp.require_string_body(request)
  let decode_result = json.parse(body, eval_decoder())
  case decode_result {
    Error(_) -> wisp.bad_request()
    Ok(fen) -> {
      let board = board.from_fen(fen)
      let eval = eval.evaluate(board, ctx.piece_square_tables)
      wisp.ok()
      // Add plus sign before positive values
      |> wisp.string_body(
        case eval >= 0 {
          True -> "+"
          False -> ""
        }
        <> int.to_string(eval),
      )
    }
  }
}
