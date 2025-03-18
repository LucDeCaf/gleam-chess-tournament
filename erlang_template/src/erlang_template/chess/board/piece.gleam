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

pub const valid_promotion_pieces = [Knight, Bishop, Rook, Queen]
