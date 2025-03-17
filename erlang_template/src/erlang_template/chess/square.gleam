import gleam/int

pub type Square {
  A1
  B1
  C1
  D1
  E1
  F1
  G1
  H1
  A2
  B2
  C2
  D2
  E2
  F2
  G2
  H2
  A3
  B3
  C3
  D3
  E3
  F3
  G3
  H3
  A4
  B4
  C4
  D4
  E4
  F4
  G4
  H4
  A5
  B5
  C5
  D5
  E5
  F5
  G5
  H5
  A6
  B6
  C6
  D6
  E6
  F6
  G6
  H6
  A7
  B7
  C7
  D7
  E7
  F7
  G7
  H7
  A8
  B8
  C8
  D8
  E8
  F8
  G8
  H8
}

pub fn index(square) {
  case square {
    A1 -> 0
    B1 -> 1
    C1 -> 2
    D1 -> 3
    E1 -> 4
    F1 -> 5
    G1 -> 6
    H1 -> 7
    A2 -> 8
    B2 -> 9
    C2 -> 10
    D2 -> 11
    E2 -> 12
    F2 -> 13
    G2 -> 14
    H2 -> 15
    A3 -> 16
    B3 -> 17
    C3 -> 18
    D3 -> 19
    E3 -> 20
    F3 -> 21
    G3 -> 22
    H3 -> 23
    A4 -> 24
    B4 -> 25
    C4 -> 26
    D4 -> 27
    E4 -> 28
    F4 -> 29
    G4 -> 30
    H4 -> 31
    A5 -> 32
    B5 -> 33
    C5 -> 34
    D5 -> 35
    E5 -> 36
    F5 -> 37
    G5 -> 38
    H5 -> 39
    A6 -> 40
    B6 -> 41
    C6 -> 42
    D6 -> 43
    E6 -> 44
    F6 -> 45
    G6 -> 46
    H6 -> 47
    A7 -> 48
    B7 -> 49
    C7 -> 50
    D7 -> 51
    E7 -> 52
    F7 -> 53
    G7 -> 54
    H7 -> 55
    A8 -> 56
    B8 -> 57
    C8 -> 58
    D8 -> 59
    E8 -> 60
    F8 -> 61
    G8 -> 62
    H8 -> 63
  }
}

pub fn bitboard(square) {
  int.bitwise_shift_left(1, index(square))
}

pub fn from_index(value: Int) -> Result(Square, Nil) {
  case value >= 0 && value <= 63 {
    True -> Ok(from_index_unchecked(value))
    False -> Error(Nil)
  }
}

pub fn from_index_unchecked(value: Int) -> Square {
  case value {
    0 -> A1
    1 -> B1
    2 -> C1
    3 -> D1
    4 -> E1
    5 -> F1
    6 -> G1
    7 -> H1
    8 -> A2
    9 -> B2
    10 -> C2
    11 -> D2
    12 -> E2
    13 -> F2
    14 -> G2
    15 -> H2
    16 -> A3
    17 -> B3
    18 -> C3
    19 -> D3
    20 -> E3
    21 -> F3
    22 -> G3
    23 -> H3
    24 -> A4
    25 -> B4
    26 -> C4
    27 -> D4
    28 -> E4
    29 -> F4
    30 -> G4
    31 -> H4
    32 -> A5
    33 -> B5
    34 -> C5
    35 -> D5
    36 -> E5
    37 -> F5
    38 -> G5
    39 -> H5
    40 -> A6
    41 -> B6
    42 -> C6
    43 -> D6
    44 -> E6
    45 -> F6
    46 -> G6
    47 -> H6
    48 -> A7
    49 -> B7
    50 -> C7
    51 -> D7
    52 -> E7
    53 -> F7
    54 -> G7
    55 -> H7
    56 -> A8
    57 -> B8
    58 -> C8
    59 -> D8
    60 -> E8
    61 -> F8
    62 -> G8
    63 -> H8
    _ ->
      panic as {
        "invalid value for square.to_square call: " <> int.to_string(value)
      }
  }
}

pub fn to_string(square: Square) -> String {
  case square {
    A1 -> "a1"
    B1 -> "b1"
    C1 -> "c1"
    D1 -> "d1"
    E1 -> "e1"
    F1 -> "f1"
    G1 -> "g1"
    H1 -> "h1"
    A2 -> "a2"
    B2 -> "b2"
    C2 -> "c2"
    D2 -> "d2"
    E2 -> "e2"
    F2 -> "f2"
    G2 -> "g2"
    H2 -> "h2"
    A3 -> "a3"
    B3 -> "b3"
    C3 -> "c3"
    D3 -> "d3"
    E3 -> "e3"
    F3 -> "f3"
    G3 -> "g3"
    H3 -> "h3"
    A4 -> "a4"
    B4 -> "b4"
    C4 -> "c4"
    D4 -> "d4"
    E4 -> "e4"
    F4 -> "f4"
    G4 -> "g4"
    H4 -> "h4"
    A5 -> "a5"
    B5 -> "b5"
    C5 -> "c5"
    D5 -> "d5"
    E5 -> "e5"
    F5 -> "f5"
    G5 -> "g5"
    H5 -> "h5"
    A6 -> "a6"
    B6 -> "b6"
    C6 -> "c6"
    D6 -> "d6"
    E6 -> "e6"
    F6 -> "f6"
    G6 -> "g6"
    H6 -> "h6"
    A7 -> "a7"
    B7 -> "b7"
    C7 -> "c7"
    D7 -> "d7"
    E7 -> "e7"
    F7 -> "f7"
    G7 -> "g7"
    H7 -> "h7"
    A8 -> "a8"
    B8 -> "b8"
    C8 -> "c8"
    D8 -> "d8"
    E8 -> "e8"
    F8 -> "f8"
    G8 -> "g8"
    H8 -> "h8"
  }
}
