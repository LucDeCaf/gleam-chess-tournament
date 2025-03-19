import erlang_template/chess/board/color
import erlang_template/chess/board/square
import erlang_template/chess/move_gen/move_tables
import gleeunit/should

pub fn move_tables_en_passant_source_mask_test() {
  let move_tables = move_tables.new()
  move_tables.en_passant_source_masks(square.E3, color.Black, move_tables)
  |> should.equal(0x28000000)
  move_tables.en_passant_source_masks(square.D6, color.White, move_tables)
  |> should.equal(0x1400000000)
  move_tables.en_passant_source_masks(square.H6, color.White, move_tables)
  |> should.equal(0x4000000000)
  move_tables.en_passant_source_masks(square.H6, color.Black, move_tables)
  |> should.equal(0x40000000000000)
}
