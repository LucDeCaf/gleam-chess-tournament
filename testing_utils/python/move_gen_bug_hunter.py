import chess
import requests

start_fen = input('Enter fen: ')

MAX_DEPTH = 10

board = chess.Board(start_fen)


def move_diffs(board: chess.Board, perft_depth=1):
    fen = board.fen
    request_body = {
        "fen": fen,
        "depth": perft_depth,
    }

    # Response will look like { "a1a1": 1234, "a1a2": 5768, ... }
    response = requests.post("http://localhost:8000/divide", json=request_body)

    generated_move_results = response.json()
    generated_moves = generated_move_results.keys()
    actual_moves = list(board.legal_moves)

    gen_move_set = set(generated_moves)
    act_move_set = set(actual_moves)

    missing_moves = act_move_set.difference(gen_move_set)
    extra_moves = gen_move_set.difference(act_move_set)
    found_moves = act_move_set.intersection(gen_move_set)

    comparison_results = {}
    for uci in found_moves:
        board.push(chess.Move.from_uci(uci))
        generated_count = generated_move_results[uci]
        actual_count = list(board.legal_moves).count()
        comparison_results[uci] = generated_count - actual_count
        board.pop()

    return {
        "shared": found_moves,
        "not_found": missing_moves,
        "illegal": extra_moves
    }
