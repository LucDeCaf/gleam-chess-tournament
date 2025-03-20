import erlang_template/chess/board/color
import erlang_template/chess/board/square
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import glearray

pub const starting_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

const white_piece_chars = ["P", "N", "B", "R", "Q", "K"]

const black_piece_chars = ["p", "n", "b", "r", "q", "k"]

// TODO: More efficient funcs from getting whole board from fen in one call

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

pub fn color(fen: String) -> color.Color {
  let assert Ok(color_string) =
    fen |> string.split(" ") |> list.take(2) |> list.last
  case color_string {
    "w" -> color.White
    "b" -> color.Black
    _ -> panic as { "invalid fen color section '" <> color_string <> "'" }
  }
}

pub fn castling_rights(fen: String) -> Int {
  let assert Ok(castling_rights) =
    fen |> string.split(" ") |> list.take(3) |> list.last

  let white_kingside = case castling_rights |> string.contains("K") {
    True -> 0b0001
    False -> 0
  }
  let white_queenside = case castling_rights |> string.contains("Q") {
    True -> 0b0010
    False -> 0
  }
  let black_kingside = case castling_rights |> string.contains("k") {
    True -> 0b0100
    False -> 0
  }
  let black_queenside = case castling_rights |> string.contains("q") {
    True -> 0b1000
    False -> 0
  }
  white_kingside
  |> int.bitwise_or(white_queenside)
  |> int.bitwise_or(black_kingside)
  |> int.bitwise_or(black_queenside)
}

pub fn en_passant(fen: String) -> option.Option(square.Square) {
  let assert Ok(ep_string) =
    fen |> string.split(" ") |> list.take(4) |> list.last
  option.from_result(square.from_string(ep_string))
}
