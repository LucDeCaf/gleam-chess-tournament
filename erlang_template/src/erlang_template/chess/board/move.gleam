import erlang_template/chess/board/flags
import erlang_template/chess/board/piece
import erlang_template/chess/board/square
import gleam/int
import gleam/option.{None, Some}

const from_mask = 0b1111110000000000

const to_mask = 0b0000001111110000

const flags_mask = 0b0000000000001111

pub type Move =
  Int

pub fn new(from: square.Square, to: square.Square, flags: flags.Flags) {
  let from_mask =
    square.index(from)
    |> int.bitwise_shift_left(10)
    |> int.bitwise_and(from_mask)
  let to_mask =
    square.index(to)
    |> int.bitwise_shift_left(4)
    |> int.bitwise_and(to_mask)
  let flags_mask = flags |> int.bitwise_and(flags_mask)

  from_mask |> int.bitwise_or(to_mask) |> int.bitwise_or(flags_mask)
}

pub fn source(move: Move) -> square.Square {
  move |> int.bitwise_shift_right(10) |> square.from_index_unchecked
}

pub fn target(move: Move) -> square.Square {
  move
  |> int.bitwise_and(to_mask)
  |> int.bitwise_shift_right(4)
  |> square.from_index_unchecked
}

pub fn flags(move: Move) -> Int {
  move |> int.bitwise_and(flags_mask)
}

pub fn promotion(move: Move) {
  let flags = move |> flags
  let is_promotion = { flags |> int.bitwise_and(flags.promotion) } != 0
  case is_promotion {
    True ->
      Some(case flags |> int.bitwise_and(0b11) {
        0 -> piece.Knight
        0b01 -> piece.Bishop
        0b10 -> piece.Rook
        0b11 -> piece.Queen
        _ -> panic as "unreachable"
      })
    False -> None
  }
}

pub fn is_capture(move: Move) -> Bool {
  int.bitwise_and(move, flags.capture) != 0
}

pub fn to_string(move: Move) -> String {
  let source = source(move)
  let target = target(move)
  let promotion = case promotion(move) {
    Some(piece) ->
      case piece {
        piece.Knight -> "n"
        piece.Bishop -> "b"
        piece.Rook -> "r"
        piece.Queen -> "q"
        _ -> ""
      }
    None -> ""
  }
  square.to_string(source) <> square.to_string(target) <> promotion
}

pub fn to_debug_string(move: Move) -> String {
  let from = source(move)
  let to = target(move)
  "{ from: "
  <> square.to_string(from)
  <> ", to: "
  <> square.to_string(to)
  <> " }"
}
