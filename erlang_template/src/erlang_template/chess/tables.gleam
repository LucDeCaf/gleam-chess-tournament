import erlang_template/chess/board/square
import glearray

pub type TableGetter(a) =
  fn(square.Square) -> a

pub fn make_table_getter(array: glearray.Array(a)) -> TableGetter(a) {
  fn(square: square.Square) {
    let assert Ok(mask) = array |> glearray.get(square |> square.index)
    mask
  }
}
