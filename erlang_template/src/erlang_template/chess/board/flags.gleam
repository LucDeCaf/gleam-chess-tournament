import erlang_template/chess/board/piece
import gleam/int
import gleam/option.{type Option, None, Some}

pub const capture = 0b0100

pub const promotion = 0b1000

pub const board_state_mask = 0b11

pub const flags_mask = 0b1111

pub const en_passant = 0b01

pub const double_move = 0b01

pub const castle_kingside = 0b10

pub const castle_queenside = 0b11

pub type Flags =
  Int

pub fn new(
  promotion_piece: Option(piece.Piece),
  is_capture: Bool,
  given_flags: Int,
) -> Flags {
  let promotion = case promotion_piece {
    Some(piece) ->
      int.bitwise_or(promotion, case piece {
        piece.Bishop -> 0b01
        piece.Rook -> 0b10
        piece.Queen -> 0b11
        // Invalid promotions are interpreted as knight promotion
        _ -> 0
      })
    None -> 0
  }

  let capture = case is_capture {
    True -> capture
    False -> 0
  }

  // Only use special flags if not a promotion, otherwise they would clash
  let special = case promotion == 0 {
    True -> given_flags
    False -> 0
  }

  promotion
  |> int.bitwise_or(capture)
  |> int.bitwise_or(special)
}
