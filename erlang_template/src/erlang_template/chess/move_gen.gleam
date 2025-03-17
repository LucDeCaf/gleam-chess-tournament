import erlang_template/chess/bitboard
import erlang_template/chess/board
import erlang_template/chess/move
import erlang_template/chess/move_tables
import erlang_template/chess/piece
import erlang_template/chess/square
import gleam/int
import gleam/list
import glearray

pub fn legal_moves(board: board.Board, move_tables) -> List(move.Move) {
  list.filter(pseudolegal_moves(board, move_tables), fn(move) {
    board.is_legal_move(board, move)
  })
}

fn pseudolegal_moves(board: board.Board, move_tables) -> List(move.Move) {
  // TODO: Move generator
  let knight_moves = knight_moves(board, move_tables)

  knight_moves
}

pub fn knight_moves(
  board: board.Board,
  move_tables: move_tables.MoveTables,
) -> List(move.Move) {
  let knights = board.bitboard(board, piece.Knight, board.color)
  let friendly_pieces = board.color_bitboard(board, board.color)
  let not_friendly_pieces = int.bitwise_not(friendly_pieces)

  knights
  |> bitboard.map_index(fn(source_i) {
    let source_square = square.from_index_unchecked(source_i)

    let assert Ok(targets) = move_tables.knight_table |> glearray.get(source_i)
    let valid_targets = targets |> int.bitwise_and(not_friendly_pieces)

    use target_i <- bitboard.map_index(valid_targets)
    let target_square = square.from_index_unchecked(target_i)
    let move = move.new(source_square, target_square)
    move
  })
  |> list.flatten
}
