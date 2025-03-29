import erlang_template/chess/tables/move_tables

pub type Context {
  Context(move_tables: move_tables.MoveTables)
}
