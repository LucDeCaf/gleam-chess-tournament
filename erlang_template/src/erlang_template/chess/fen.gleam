import gleam/int
import gleam/list
import gleam/string
import glearray

pub const starting_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

const white_piece_chars = ["P", "N", "B", "R", "Q", "K"]

const black_piece_chars = ["p", "n", "b", "r", "q", "k"]

pub fn pieces(fen: String) -> glearray.Array(Int) {
  let assert Ok(pieces) = fen |> string.split(" ") |> list.first
  pieces
  |> string.split("/")
  |> list.map(fn(line) {
    list.map(
      [
        ["p", "P"],
        ["n", "N"],
        ["b", "B"],
        ["r", "R"],
        ["q", "Q"],
        ["k", "K"],
        white_piece_chars,
        black_piece_chars,
      ],
      fn(piece_chars) { accumulate_pieces(line, piece_chars) },
    )
  })
  |> list.fold([0, 0, 0, 0, 0, 0, 0, 0], fn(a, b) {
    list.zip(a, b)
    |> list.map(fn(a) { int.bitwise_or(int.bitwise_shift_left(a.0, 8), a.1) })
  })
  |> glearray.from_list
}

fn accumulate_pieces(line: String, piece_chars: List(String)) -> Int {
  accumulate_pieces_inner(line, piece_chars, 0, 0)
}

fn accumulate_pieces_inner(
  line: String,
  piece_chars: List(String),
  position: Int,
  pieces_so_far: Int,
) -> Int {
  case position > 7 {
    True -> pieces_so_far

    False -> {
      let assert Ok(current_char) = string.first(line)
      let #(next_position, piece_found) =
        get_piece(current_char, piece_chars, position)

      let pieces_so_far =
        pieces_so_far
        |> int.bitwise_or(case piece_found {
          True -> int.bitwise_shift_left(1, position)
          False -> 0
        })

      let remaining_line = string.slice(line, 1, 8)
      let all_pieces =
        accumulate_pieces_inner(
          remaining_line,
          piece_chars,
          next_position,
          pieces_so_far,
        )

      all_pieces
    }
  }
}

/// Takes in a character and returns whether that character is a valid piece + the new position of the cursor in the line
/// 
/// Positions greater than 7 will always return `#(8, False)`.
/// 
/// Returns `#(new_position, piece_found)`
fn get_piece(
  char: String,
  piece_chars: List(String),
  position: Int,
) -> #(Int, Bool) {
  // Don't check for pieces past `position == 7`
  case position > 7 {
    True -> #(8, False)
    False ->
      case char {
        "1" | "2" | "3" | "4" | "5" | "6" | "7" -> {
          // Increase position, no pieces added
          let assert Ok(offset) = int.base_parse(char, 10)
          #(position + offset, False)
        }
        "8" -> #(8, False)
        _ -> #(position + 1, piece_chars |> list.contains(any: char))
      }
  }
}
