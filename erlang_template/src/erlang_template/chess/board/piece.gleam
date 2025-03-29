pub type Piece {
  Pawn
  Knight
  Bishop
  Rook
  Queen
  King
}

pub fn index(piece) {
  case piece {
    Pawn -> 0
    Knight -> 1
    Bishop -> 2
    Rook -> 3
    Queen -> 4
    King -> 5
  }
}

pub fn from_index(i) {
  case i {
    0 -> Ok(Pawn)
    1 -> Ok(Knight)
    2 -> Ok(Bishop)
    3 -> Ok(Rook)
    4 -> Ok(Queen)
    5 -> Ok(King)
    _ -> Error(Nil)
  }
}

pub const all_pieces = [Pawn, Knight, Bishop, Rook, Queen, King]

pub const valid_promotion_pieces = [Knight, Bishop, Rook, Queen]
