import erlang_template/chess/board/square
import glearray

pub type TableGetter =
  fn(square.Square) -> Int

pub fn make_table_getter(array: glearray.Array(Int)) -> TableGetter {
  fn(square: square.Square) {
    let assert Ok(mask) = array |> glearray.get(square |> square.index)
    mask
  }
}
