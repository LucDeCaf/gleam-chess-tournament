pub type Color {
  White
  Black
}

pub fn inverse(color) {
  case color {
    White -> Black
    Black -> White
  }
}

pub fn index(color) {
  case color {
    White -> 0
    Black -> 1
  }
}

pub fn sign(color) {
  case color {
    White -> 1
    Black -> -1
  }
}
