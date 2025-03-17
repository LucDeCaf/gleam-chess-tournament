import erlang_template/chess/square
import gleam/int

const from_mask = 0b1111110000000000

const to_mask = 0b0000001111110000

const flags_mask = 0b0000000000001111

pub type Move =
  Int

pub fn new_move(from: square.Square, to: square.Square) {
  let from_mask = square.index(from) |> int.bitwise_shift_left(10)
  let to_mask = square.index(to) |> int.bitwise_shift_left(4)
  // TODO: Decide on move flags
  let flags_mask = 0

  from_mask |> int.bitwise_or(to_mask) |> int.bitwise_or(flags_mask)
}

pub fn from(move: Move) {
  int.bitwise_shift_right(move, 10)
}

pub fn to(move: Move) {
  int.bitwise_and(int.bitwise_shift_right(move, 6), to_mask)
}

pub fn flags(move: Move) {
  int.bitwise_and(move, flags_mask)
}
