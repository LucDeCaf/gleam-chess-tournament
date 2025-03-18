import gleam/float
import gleam/int

pub type MagicEntry {
  MagicEntry(mask: Int, magic: Int, shift: Int, offset: Int)
}

pub fn magic_index(entry: MagicEntry, blockers: Int) -> Int {
  let blockers = blockers |> int.bitwise_and(entry.mask)
  let hash = blockers |> wrapping_mul(entry.magic)
  let index = hash |> int.bitwise_shift_right(entry.shift)
  entry.offset + index
}

fn wrapping_mul(a: Int, b: Int) -> Int {
  let assert Ok(pow) = int.power(2, 64.0)
  { a * b } % float.truncate(pow)
}
