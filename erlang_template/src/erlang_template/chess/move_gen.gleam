import erlang_template/chess/bitboard
import erlang_template/chess/board
import erlang_template/chess/color
import erlang_template/chess/move
import erlang_template/chess/move_tables
import erlang_template/chess/piece
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

fn knight_moves(
  board: board.Board,
  move_tables: move_tables.MoveTables,
) -> List(move.Move) {
  let knights = board.bitboard(board, piece.Knight, board.color)
  let friendly_pieces = board.color_bitboard(board, board.color)

  knights
  |> bitboard.map(fn(i) {
    let assert Ok(knight_moves) = glearray.get(move_tables.knight_table, i)
    int.bitwise_and(knight_moves, int.bitwise_not(friendly_pieces))
  })
}
