import erlang_template/chess/square
import gleam/float
import gleam/int
import gleam/list
import gleam_community/maths/elementary

pub type Bitboard =
  Int

pub fn squares(bitboard: Bitboard) -> List(square.Square) {
  // Enforce 64-bit integer (no extra bits)
  bitboard
  |> int.bitwise_and(0xffffffffffffffff)
  |> map(square.from_index_unchecked)
}

pub fn map(bitboard: Bitboard, with cb: fn(Int) -> b) -> List(b) {
  map_inner(bitboard, cb, [])
}

fn map_inner(bitboard: Bitboard, cb: fn(Int) -> b, accum: List(b)) -> List(b) {
  case bitboard {
    0 -> list.reverse(accum)
    _ -> {
      let bitboard_minus_lsb = pop_lsb(bitboard)
      let i = { bitboard - int.bitwise_not(bitboard_minus_lsb) } / 2
      map_inner(bitboard_minus_lsb, cb, [cb(i), ..accum])
    }
  }
}

/// Map function where each value is the position of a set bit, starting from the LSB.
pub fn map_index(bitboard: Bitboard, cb: fn(Int) -> b) -> List(b) {
  map_index_inner(bitboard, cb, [])
}

pub fn map_index_inner(
  bitboard: Bitboard,
  cb: fn(Int) -> b,
  accum: List(b),
) -> List(b) {
  case bitboard {
    0 -> list.reverse(accum)
    _ -> {
      let bitboard_minus_lsb = pop_lsb(bitboard)
      let new_lsb_index = lsb_index(bitboard)
      map_index_inner(bitboard_minus_lsb, cb, [cb(new_lsb_index), ..accum])
    }
  }
}

pub fn popcount(value: Int) {
  popcount_inner(value, 0)
}

fn popcount_inner(value: Int, count: Int) -> Int {
  case value == 0 {
    True -> count
    False -> popcount_inner(pop_lsb(value), count + 1)
  }
}

pub fn pop_lsb(bitboard: Bitboard) -> Int {
  case bitboard > 0 {
    True -> int.bitwise_and(bitboard, bitboard - 1)
    False -> 0
  }
}

// TODO: Rewrite to use precomputed tables for 8 bit ints and to check the different 
// TODO: sections of the bitboard by splitting it into 8 bit chunks
pub fn lsb_index(bitboard: Bitboard) -> Int {
  case bitboard {
    0 -> -1
    _ -> {
      let assert Ok(log_result) =
        elementary.logarithm_2(
          int.bitwise_and(bitboard, -bitboard) |> int.to_float,
        )
      float.truncate(log_result)
    }
  }
}
