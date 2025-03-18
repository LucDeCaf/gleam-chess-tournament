import erlang_template/chess/move_gen/move_tables

pub type Context {
  Context(move_tables: move_tables.MoveTables)
}
