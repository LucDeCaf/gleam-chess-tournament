import erlang_template/chess/tables
import glearray

const pawn_middlegame = [
  0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 100, 100, 100, 100, 100, 100, -20, -15, 15,
  60, 60, 15, -15, -20, -20, -15, 20, 60, 60, 20, -15, -20, -20, -30, 50, 50, 50,
  -20, -40, -20, 15, -20, -20, -10, -10, -80, 10, 15, 15, 15, 15, -30, -30, 15,
  15, 15, 0, 0, 0, 0, 0, 0, 0, 0,
]

const pawn_endgame = [
  0, 0, 0, 0, 0, 0, 0, 0, 180, 160, 150, 140, 140, 150, 160, 180, 90, 90, 80, 80,
  80, 80, 90, 90, 30, 30, 30, 30, 30, 30, 30, 30, 20, 20, 20, 20, 20, 20, 20, 20,
  15, 15, 15, 15, 15, 15, 15, 15, 10, 10, 10, 10, 10, 10, 10, 10, 0, 0, 0, 0, 0,
  0, 0, 0,
]

const knight_middlegame = [
  -150, -80, -40, -40, -40, -40, -80, -150, -100, -50, -40, -40, -40, -40, -50,
  -100, -75, 10, 15, 20, 20, 15, 10, -75, -50, 0, 40, 50, 50, 40, 0, -50, -50, 0,
  30, 50, 50, 30, 0, -50, -75, -10, 20, 15, 15, 20, -10, -75, -100, -40, -30,
  -10, -10, -30, -40, -100, -150, -50, -50, -80, -80, 50, -50, -150,
]

const knight_endgame = [
  -60, -40, -20, -20, -20, -20, -40, -60, -40, -20, -10, -10, -10, -10, -20, -40,
  -30, 0, 10, 10, 10, 10, 0, -30, -20, 5, 20, 25, 25, 20, 5, -20, -20, 5, 20, 25,
  25, 20, 5, -20, -30, 0, 10, 20, 20, 10, 0, -30, -50, -30, -20, -10, -10, -20,
  -30, -50, -80, -60, -50, -50, -50, -50, -60, -80,
]

const bishop_middlegame = [
  -50, -20, -60, -60, -60, -60, -20, -50, -35, 15, -10, -20, -20, -10, 15, -35,
  -15, 20, 30, 30, 30, 30, 20, -15, -10, 60, 50, 50, 50, 50, 60, -10, -10, 0, 60,
  70, 70, 60, 0, -10, 0, 15, 40, 50, 50, 40, 15, 0, 0, 30, 20, 20, 20, 20, 30, 0,
  20, -40, -50, -80, -80, -50, -40, 20,
]

const bishop_endgame = [
  -15, -10, -10, -10, -10, -10, -10, -15, -10, 0, 0, 0, 0, 0, 0, -10, -5, 0, 0,
  5, 5, 0, 0, -5, -5, 0, 20, 25, 25, 20, 0, -5, -5, 0, 20, 25, 25, 20, 0, -5, -5,
  0, 0, 5, 5, 0, 0, -5, -10, 0, 0, 0, 0, 0, 0, -10, -15, -10, -20, 0, 0, -20,
  -10, -15,
]

const rook_middlegame = [
  40, 40, 40, 50, 50, 40, 40, 40, 50, 60, 60, 80, 80, 60, 60, 50, 10, 15, 15, 20,
  20, 15, 15, 10, -20, -10, 20, 20, 20, 20, -10, -20, -20, -10, 0, 0, 0, 0, -10,
  -20, -20, -15, -15, 0, 0, -15, -15, -20, -40, -15, -15, 30, 30, 20, -15, -40,
  -30, -30, 20, 30, 30, 10, -30, -30,
]

const rook_endgame = [
  20, 20, 20, 20, 20, 20, 20, 20, 10, 10, 10, 10, 10, 10, 10, 10, 5, 5, 5, 5, 5,
  5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -5, -5, -5, -5, -5,
  -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5,
]

const queen_middlegame = [
  15, 30, 30, 30, 30, 30, 30, 30, -25, -10, -10, 0, 0, 40, 50, 50, -20, -10, -10,
  0, 0, 20, 20, 20, -20, -10, -10, 0, 0, -20, -20, -20, -20, -10, -10, 10, 10,
  -20, -20, -20, -20, 15, 15, 10, 10, 15, 20, 20, -20, -10, 20, 20, 20, 15, -10,
  -20, -50, -40, -30, 10, 10, -30, -40, -50,
]

const queen_endgame = [
  20, 30, 50, 50, 50, 50, 20, 20, 20, 30, 50, 50, 50, 50, 20, 20, 10, 20, 30, 30,
  30, 30, 20, 10, 10, 20, 30, 40, 40, 30, 20, 10, 10, 20, 30, 40, 40, 30, 20, 10,
  -10, -10, -10, -10, -10, -10, -10, -10, -20, -20, -20, -20, -20, -20, -20, -20,
  -20, -20, -20, -20, -20, -20, -20, -20,
]

const king_middlegame = [
  -80, -80, -80, -80, -80, -80, -80, -80, -60, -60, -60, -60, -60, -60, -60, -60,
  -50, -50, -50, -50, -50, -50, -50, -50, -30, -30, -30, -60, -60, -30, -30, -30,
  -20, -20, -20, -60, -60, -20, -20, -20, -10, -10, -30, -50, -50, -30, -10, -10,
  0, -10, -10, -50, -50, -10, -10, 0, 20, 25, 20, -20, -20, -10, 25, 20,
]

const king_endgame = [
  -50, -20, 10, 10, 10, 10, -20, -50, -20, 20, 25, 25, 25, 25, 20, -20, 0, 25,
  25, 25, 25, 25, 25, 0, 0, 25, 25, 25, 25, 25, 25, 0, -10, 0, 15, 15, 15, 15, 0,
  -10, -10, 0, 5, 5, 5, 5, 0, -10, -30, -20, -10, -10, -10, -10, -20, -30, -50,
  -30, -20, -20, -20, -20, -30, -50,
]

pub type PieceSquareTables {
  PieceSquareTables(
    pawn_middlegame: tables.TableGetter,
    pawn_endgame: tables.TableGetter,
    knight_middlegame: tables.TableGetter,
    knight_endgame: tables.TableGetter,
    bishop_middlegame: tables.TableGetter,
    bishop_endgame: tables.TableGetter,
    rook_middlegame: tables.TableGetter,
    rook_endgame: tables.TableGetter,
    queen_middlegame: tables.TableGetter,
    queen_endgame: tables.TableGetter,
    king_middlegame: tables.TableGetter,
    king_endgame: tables.TableGetter,
  )
}

pub fn new() {
  let pawn_middlegame_table = glearray.from_list(pawn_middlegame)
  let pawn_endgame_table = glearray.from_list(pawn_endgame)
  let knight_middlegame_table = glearray.from_list(knight_middlegame)
  let knight_endgame_table = glearray.from_list(knight_endgame)
  let bishop_middlegame_table = glearray.from_list(bishop_middlegame)
  let bishop_endgame_table = glearray.from_list(bishop_endgame)
  let rook_middlegame_table = glearray.from_list(rook_middlegame)
  let rook_endgame_table = glearray.from_list(rook_endgame)
  let queen_middlegame_table = glearray.from_list(queen_middlegame)
  let queen_endgame_table = glearray.from_list(queen_endgame)
  let king_middlegame_table = glearray.from_list(king_middlegame)
  let king_endgame_table = glearray.from_list(king_endgame)

  PieceSquareTables(
    pawn_middlegame: tables.make_table_getter(pawn_middlegame_table),
    pawn_endgame: tables.make_table_getter(pawn_endgame_table),
    knight_middlegame: tables.make_table_getter(knight_middlegame_table),
    knight_endgame: tables.make_table_getter(knight_endgame_table),
    bishop_middlegame: tables.make_table_getter(bishop_middlegame_table),
    bishop_endgame: tables.make_table_getter(bishop_endgame_table),
    rook_middlegame: tables.make_table_getter(rook_middlegame_table),
    rook_endgame: tables.make_table_getter(rook_endgame_table),
    queen_middlegame: tables.make_table_getter(queen_middlegame_table),
    queen_endgame: tables.make_table_getter(queen_endgame_table),
    king_middlegame: tables.make_table_getter(king_middlegame_table),
    king_endgame: tables.make_table_getter(king_endgame_table),
  )
}
