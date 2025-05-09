import erlang_template/chess/tables/move_tables
import erlang_template/chess/tables/piece_square_tables

pub type Context {
  Context(
    move_tables: move_tables.MoveTables,
    piece_square_tables: piece_square_tables.PieceSquareTables,
  )
}
