import erlang_template/chess/board
import erlang_template/chess/board/color
import erlang_template/chess/board/flags
import erlang_template/chess/board/move
import erlang_template/chess/board/square
import erlang_template/chess/fen
import erlang_template/chess/move_gen
import erlang_template/chess/move_gen/move_tables
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleeunit/should

pub fn pawn_moves_test() {
  let board =
    board.Board(
      pieces: fen.pieces(fen.starting_fen),
      color: color.White,
      castling_rights: 0b1111,
      en_passant: None,
    )
  let moves = move_gen.pawn_straight_moves(board) |> list.sort(int.compare)
  let expected_moves =
    [
      move.new(square.A2, square.A3, 0),
      move.new(square.A2, square.A4, flags.double_move),
      move.new(square.B2, square.B3, 0),
      move.new(square.B2, square.B4, flags.double_move),
      move.new(square.C2, square.C3, 0),
      move.new(square.C2, square.C4, flags.double_move),
      move.new(square.D2, square.D3, 0),
      move.new(square.D2, square.D4, flags.double_move),
      move.new(square.E2, square.E3, 0),
      move.new(square.E2, square.E4, flags.double_move),
      move.new(square.F2, square.F3, 0),
      move.new(square.F2, square.F4, flags.double_move),
      move.new(square.G2, square.G3, 0),
      move.new(square.G2, square.G4, flags.double_move),
      move.new(square.H2, square.H3, 0),
      move.new(square.H2, square.H4, flags.double_move),
    ]
    |> list.sort(int.compare)

  use testcase <- list.each(list.zip(moves, expected_moves))
  testcase.0 |> should.equal(testcase.1)
}

pub fn pawn_captures_test() {
  // Custom fen with many pawn captures / moves
  let pawn_test_fen =
    "rnbqkb1r/p1p1pppp/8/2PpP3/8/1p3P1n/PP1P2PP/RNBQKBNR w KQkq - 0 1"

  let board =
    board.Board(
      pieces: fen.pieces(pawn_test_fen),
      color: color.White,
      castling_rights: 0b1111,
      en_passant: Some(square.D6),
    )
  let move_tables = move_tables.new()

  let moves =
    move_gen.pawn_captures(board, move_tables) |> list.sort(int.compare)
  let expected_moves =
    [
      move.new(square.C5, square.D6, flags.new(None, True, flags.en_passant)),
      move.new(square.E5, square.D6, flags.new(None, True, flags.en_passant)),
      move.new(square.E5, square.F6, flags.capture),
      move.new(square.A2, square.B3, flags.capture),
      move.new(square.G2, square.H3, flags.capture),
    ]
    |> list.sort(int.compare)

  let white_testcases = list.zip(moves, expected_moves)

  // Update EP square and test with black pawns
  let board =
    board.Board(
      pieces: fen.pieces(pawn_test_fen),
      color: color.Black,
      castling_rights: 0b1111,
      en_passant: Some(square.E4),
    )

  let moves =
    move_gen.pawn_captures(board, move_tables) |> list.sort(int.compare)
  let expected_moves =
    [
      move.new(square.A7, square.B6, flags.capture),
      move.new(square.C7, square.B6, flags.capture),
      move.new(square.B3, square.A2, flags.capture),
      move.new(square.D5, square.E4, flags.new(None, True, flags.en_passant)),
      move.new(square.F6, square.E5, flags.capture),
    ]
    |> list.sort(int.compare)

  let black_testcases = list.zip(moves, expected_moves)

  use testcase <- list.each(list.append(white_testcases, black_testcases))
  testcase.0 |> should.equal(testcase.1)
}

pub fn sliding_targets_test() {
  let blockers = 0x8120012000140000
  let square = square.F6

  let expected_bishop_moves = 0x8850005088040000
  let expected_rook_moves = 0x20df2000000000

  move_tables.sliding_targets(square, blockers, move_tables.rook_move_shifts)
  |> should.equal(expected_rook_moves)
  move_tables.sliding_targets(square, blockers, move_tables.bishop_move_shifts)
  |> should.equal(expected_bishop_moves)

  let square = square.A1
  let expected_rook_moves = 0x101010101fe
  move_tables.sliding_targets(square, blockers, move_tables.rook_move_shifts)
  |> should.equal(expected_rook_moves)
}

pub fn knight_moves_test() {
  let move_tables = move_tables.new()
  let board =
    board.Board(
      pieces: fen.pieces(fen.starting_fen),
      color: color.White,
      castling_rights: 0b1111,
      en_passant: None,
    )

  let moves =
    move_gen.knight_moves(board, move_tables) |> list.sort(int.compare)
  let expected =
    [
      move.new(square.B1, square.A3, 0),
      move.new(square.B1, square.C3, 0),
      move.new(square.G1, square.H3, 0),
      move.new(square.G1, square.F3, 0),
    ]
    |> list.sort(int.compare)

  moves
  |> list.zip(expected)
  |> list.each(fn(testcase) { testcase.0 |> should.equal(testcase.1) })
}

pub fn bishop_moves_test() {
  let board = board.from_fen("n3k3/p7/1R1N2r1/2b5/1q2B3/3N4/2r3r1/4K2N w - -")
  let bishop_moves_white =
    board |> move_gen.bishop_moves |> list.sort(int.compare)

  let board = board.from_fen("n3k3/p7/1R1N2r1/2b5/1q2B3/3N4/2r3r1/4K2N b - -")
  let bishop_moves_black =
    board |> move_gen.bishop_moves |> list.sort(int.compare)

  let expected_moves_white =
    [
      move.new(square.E4, square.F5, 0),
      move.new(square.E4, square.G6, flags.capture),
      move.new(square.E4, square.F3, 0),
      move.new(square.E4, square.G2, flags.capture),
      move.new(square.E4, square.D5, 0),
      move.new(square.E4, square.C6, 0),
      move.new(square.E4, square.B7, 0),
      move.new(square.E4, square.A8, flags.capture),
    ]
    |> list.sort(int.compare)
  let expected_moves_black =
    [
      move.new(square.C5, square.B6, flags.capture),
      move.new(square.C5, square.D6, flags.capture),
      move.new(square.C5, square.D4, 0),
      move.new(square.C5, square.E3, 0),
      move.new(square.C5, square.F2, 0),
      move.new(square.C5, square.G1, 0),
    ]
    |> list.sort(int.compare)

  let white_tests =
    list.strict_zip(bishop_moves_white, expected_moves_white)
    |> should.be_ok
  let black_tests =
    list.strict_zip(bishop_moves_black, expected_moves_black)
    |> should.be_ok

  use tests <- list.each([white_tests, black_tests])
  use test_case <- list.each(tests)
  move.to_debug_string(test_case.0)
  |> should.equal(move.to_debug_string(test_case.1))
}

pub fn rook_moves_test() {
  let board = board.from_fen("3bkn2/8/8/N4rn1/1B1R2b1/8/5N2/3BK3 w - -")
  let rook_moves_white = board |> move_gen.rook_moves |> list.sort(int.compare)

  let board = board.from_fen("3bkn2/8/8/N4rn1/1B1R2b1/8/5N2/3BK3 b - -")
  let rook_moves_black = board |> move_gen.rook_moves |> list.sort(int.compare)

  let expected_moves_white =
    [
      move.new(square.D4, square.D3, 0),
      move.new(square.D4, square.D2, 0),
      move.new(square.D4, square.C4, 0),
      move.new(square.D4, square.D5, 0),
      move.new(square.D4, square.D6, 0),
      move.new(square.D4, square.D7, 0),
      move.new(square.D4, square.D8, flags.capture),
      move.new(square.D4, square.E4, 0),
      move.new(square.D4, square.F4, 0),
      move.new(square.D4, square.G4, flags.capture),
    ]
    |> list.sort(int.compare)
  let expected_moves_black =
    [
      move.new(square.F5, square.A5, flags.capture),
      move.new(square.F5, square.B5, 0),
      move.new(square.F5, square.C5, 0),
      move.new(square.F5, square.D5, 0),
      move.new(square.F5, square.E5, 0),
      move.new(square.F5, square.F2, flags.capture),
      move.new(square.F5, square.F3, 0),
      move.new(square.F5, square.F4, 0),
      move.new(square.F5, square.F6, 0),
      move.new(square.F5, square.F7, 0),
    ]
    |> list.sort(int.compare)

  let white_tests =
    list.strict_zip(rook_moves_white, expected_moves_white)
    |> should.be_ok
  let black_tests =
    list.strict_zip(rook_moves_black, expected_moves_black)
    |> should.be_ok

  use tests <- list.each([white_tests, black_tests])
  use test_case <- list.each(tests)
  move.to_debug_string(test_case.0)
  |> should.equal(move.to_debug_string(test_case.1))
}

pub fn kiwipete_captures_white_test() {
  let kiwipete_fen =
    "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -"
  let board = board.from_fen(kiwipete_fen)
  let tables = move_tables.new()

  let expected_captures =
    [
      move.new(square.E2, square.A6, flags.capture),
      move.new(square.D5, square.E6, flags.capture),
      move.new(square.E5, square.G6, flags.capture),
      move.new(square.E5, square.F7, flags.capture),
      move.new(square.E5, square.D7, flags.capture),
      move.new(square.G2, square.H3, flags.capture),
      move.new(square.F3, square.H3, flags.capture),
      move.new(square.F3, square.F6, flags.capture),
    ]
    |> list.sort(int.compare)
  let captures =
    board
    |> move_gen.legal_moves(tables)
    |> list.filter(fn(move) { int.bitwise_and(move, flags.capture) != 0 })
    |> list.sort(int.compare)

  let test_cases = list.zip(expected_captures, captures)
  use test_case <- list.each(test_cases)
  move.to_debug_string(test_case.0)
  |> should.equal(move.to_debug_string(test_case.1))
}

pub fn kiwipete_captures_black_test() {
  let kiwipete_fen =
    "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R b KQkq -"
  let board = board.from_fen(kiwipete_fen)
  let tables = move_tables.new()

  let expected_captures =
    [
      move.new(square.H3, square.G2, flags.capture),
      move.new(square.F6, square.E4, flags.capture),
      move.new(square.F6, square.D5, flags.capture),
      move.new(square.E6, square.D5, flags.capture),
      move.new(square.B6, square.D5, flags.capture),
      move.new(square.B4, square.C3, flags.capture),
      move.new(square.A6, square.E2, flags.capture),
    ]
    |> list.sort(int.compare)
  let captures =
    board
    |> move_gen.legal_moves(tables)
    |> list.filter(fn(move) { int.bitwise_and(move, flags.capture) != 0 })
    |> list.sort(int.compare)

  let test_cases = list.zip(expected_captures, captures)
  use test_case <- list.each(test_cases)
  move.to_debug_string(test_case.0)
  |> should.equal(move.to_debug_string(test_case.1))
}

pub fn en_passant_white_test() {
  let tables = move_tables.new()
  let board = board.from_fen("4k3/8/1p6/2PpPp2/8/8/8/4K3 w - d6")

  let pawn_captures =
    board |> move_gen.pawn_captures(tables) |> list.sort(int.compare)
  let expected_captures =
    [
      move.new(square.C5, square.B6, flags.capture),
      move.new(square.C5, square.D6, flags.capture),
      move.new(square.E5, square.D6, flags.capture),
    ]
    |> list.sort(int.compare)

  let test_cases = list.zip(expected_captures, pawn_captures)
  use test_case <- list.each(test_cases)
  move.to_debug_string(test_case.0)
  |> should.equal(move.to_debug_string(test_case.1))
}

pub fn en_passant_black_test() {
  let tables = move_tables.new()
  let board = board.from_fen("4k3/8/8/8/2pPpP2/1P6/8/4K3 b - d3")

  let pawn_captures =
    board |> move_gen.pawn_captures(tables) |> list.sort(int.compare)
  let expected_captures =
    [
      move.new(square.C4, square.B3, flags.capture),
      move.new(square.C4, square.D3, flags.capture),
      move.new(square.E4, square.D3, flags.capture),
    ]
    |> list.sort(int.compare)

  let test_cases = list.zip(expected_captures, pawn_captures)
  use test_case <- list.each(test_cases)
  move.to_debug_string(test_case.0)
  |> should.equal(move.to_debug_string(test_case.1))
}

pub fn is_legal_move_test() {
  let discovered_check_fen = "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - -"
  let board = board.from_fen(discovered_check_fen)
  let tables = move_tables.new()

  let legal_moves =
    board |> move_gen.legal_moves(tables) |> list.sort(int.compare)
  // Moves generated with python-chess and custom script
  let expected_moves =
    [
      move.new(square.A5, square.A6, 0),
      move.new(square.A5, square.A4, 0),
      move.new(square.B4, square.F4, 4),
      move.new(square.B4, square.E4, 0),
      move.new(square.B4, square.D4, 0),
      move.new(square.B4, square.C4, 0),
      move.new(square.B4, square.A4, 0),
      move.new(square.B4, square.B3, 0),
      move.new(square.B4, square.B2, 0),
      move.new(square.B4, square.B1, 0),
      move.new(square.G2, square.G3, 0),
      move.new(square.E2, square.E3, 0),
      move.new(square.G2, square.G4, 0),
      move.new(square.E2, square.E4, 0),
    ]
    |> list.sort(int.compare)

  let test_cases = list.zip(expected_moves, legal_moves)
  use test_case <- list.each(test_cases)
  move.to_debug_string(test_case.0)
  |> should.equal(move.to_debug_string(test_case.1))
}

pub fn square_attacked_by_test() {
  let tables = move_tables.new()
  let fen = "2q1rr1k/3bbnnp/p2p1pp1/2pPp3/PpP1P1P1/1P2BNNP/2BQ1PRK/7R b - -"
  let board = board.from_fen(fen)

  let cases = [
    #(square.A2, color.White, False),
    #(square.A2, color.Black, False),
    #(square.A7, color.White, False),
    #(square.A7, color.Black, False),
    #(square.B5, color.White, True),
    #(square.B5, color.Black, True),
    #(square.B7, color.White, False),
    #(square.B7, color.Black, True),
    #(square.C4, color.White, True),
    #(square.C4, color.Black, False),
    #(square.F4, color.White, True),
    #(square.F4, color.Black, True),
    #(square.G8, color.White, False),
    #(square.G8, color.Black, True),
    #(square.H2, color.White, True),
    #(square.H2, color.Black, False),
    #(square.H8, color.White, False),
    #(square.H8, color.Black, True),
  ]

  use test_case <- list.each(cases)
  move_gen.square_attacked_by(board, test_case.0, test_case.1, tables)
  |> should.equal(test_case.2)
}
