import erlang_template/chess/board
import erlang_template/chess/board/bitboard
import erlang_template/chess/board/color
import erlang_template/chess/board/piece
import erlang_template/chess/board/square
import erlang_template/chess/tables
import erlang_template/chess/tables/piece_square_tables
import gleam/bool
import gleam/int
import gleam/list

pub const pawn_value = 100

pub const knight_value = 300

pub const bishop_value = 320

pub const rook_value = 500

pub const queen_value = 900

pub const king_value = 0

pub fn material_with_pst(
  board: board.Board,
  pst: piece_square_tables.PieceSquareTables,
) {
  // ? Technically a bit suboptimal as board.color_bitboard is called multiple times internally
  let friendly_color = board.color
  let enemy_color = board.color |> color.inverse

  let friendly_pawns =
    apply_pst(
      board.bitboard(board, piece.Pawn, friendly_color),
      friendly_color,
      pawn_value,
      pst.pawn_middlegame,
    )
  let friendly_knights =
    apply_pst(
      board.bitboard(board, piece.Knight, friendly_color),
      friendly_color,
      knight_value,
      pst.knight_middlegame,
    )
  let friendly_bishops =
    apply_pst(
      board.bitboard(board, piece.Bishop, friendly_color),
      friendly_color,
      bishop_value,
      pst.bishop_middlegame,
    )
  let friendly_rooks =
    apply_pst(
      board.bitboard(board, piece.Rook, friendly_color),
      friendly_color,
      rook_value,
      pst.rook_middlegame,
    )
  let friendly_queens =
    apply_pst(
      board.bitboard(board, piece.Queen, friendly_color),
      friendly_color,
      queen_value,
      pst.queen_middlegame,
    )
  let friendly_kings =
    apply_pst(
      board.bitboard(board, piece.King, friendly_color),
      friendly_color,
      king_value,
      pst.king_middlegame,
    )

  let enemy_pawns =
    apply_pst(
      board.bitboard(board, piece.Pawn, enemy_color),
      enemy_color,
      pawn_value,
      pst.pawn_middlegame,
    )
  let enemy_knights =
    apply_pst(
      board.bitboard(board, piece.Knight, enemy_color),
      enemy_color,
      knight_value,
      pst.knight_middlegame,
    )
  let enemy_bishops =
    apply_pst(
      board.bitboard(board, piece.Bishop, enemy_color),
      enemy_color,
      bishop_value,
      pst.bishop_middlegame,
    )
  let enemy_rooks =
    apply_pst(
      board.bitboard(board, piece.Rook, enemy_color),
      enemy_color,
      rook_value,
      pst.rook_middlegame,
    )
  let enemy_queens =
    apply_pst(
      board.bitboard(board, piece.Queen, enemy_color),
      enemy_color,
      queen_value,
      pst.queen_middlegame,
    )
  let enemy_kings =
    apply_pst(
      board.bitboard(board, piece.King, enemy_color),
      enemy_color,
      king_value,
      pst.king_middlegame,
    )

  let total_friendly_score =
    friendly_pawns
    + friendly_knights
    + friendly_bishops
    + friendly_rooks
    + friendly_queens
    + friendly_kings
  let total_enemy_score =
    enemy_pawns
    + enemy_knights
    + enemy_bishops
    + enemy_rooks
    + enemy_queens
    + enemy_kings

  total_friendly_score - total_enemy_score
}

pub fn apply_pst(
  pieces: Int,
  color: color.Color,
  base_score: Int,
  pst_getter: tables.TableGetter,
) {
  use <- bool.guard(pieces == 0, 0)

  pieces
  |> bitboard.map_index(fn(i) {
    // TODO: Flip the PSTs if board.color == white
    let pst_square = case color {
      // Black - PST is already correct
      color.Black -> square.from_index_unchecked(i)

      // White - PST must be mirrored across x-axis
      color.White -> {
        let rank = 7 - square.rank(i)
        let file = square.file(i)
        square.from_index_unchecked(rank * 8 + file)
      }
    }

    base_score + pst_getter(pst_square)
  })
  |> list.fold(0, int.add)
}

pub fn evaluate(
  board: board.Board,
  pst: piece_square_tables.PieceSquareTables,
) -> Int {
  material_with_pst(board, pst)
}
