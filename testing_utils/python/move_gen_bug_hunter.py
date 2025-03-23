import chess
import json
import requests

DEFAULT_FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

start_fen = input('Enter fen (leave blank for starting position): ').strip()
if start_fen == "":
    start_fen = DEFAULT_FEN
perft_depth = int(input("Enter perft depth: "))

board = chess.Board(start_fen)


def perft(board: chess.Board, depth: int):
    if depth == 0:
        return 1
    if depth == 1:
        return board.legal_moves.count()

    count = 0

    for move in board.legal_moves:
        board.push(move)
        count += perft(board, depth - 1)
        board.pop()

    return count


def move_diffs(board: chess.Board, perft_depth=1):
    fen = board.fen()
    request_body = {
        "fen": fen,
        "depth": perft_depth,
    }

    # Response will look like { "a1a1": 1234, "a1a2": 5768, ... }
    generated_move_perfts = requests.post(
        "http://localhost:8000/divide",
        json=request_body
    ).json()

    # ["a1a1", "a1a2", ...]
    generated_moves = generated_move_perfts.keys()

    # ["a1a1", "a1a2", ...]
    actual_moves = [move.uci() for move in board.legal_moves]

    # Same format as above generated_move_perfts
    actual_move_perfts = {}
    for uci in actual_moves:
        board.push(chess.Move.from_uci(uci))
        actual_move_perfts[uci] = perft(board, perft_depth - 1)
        board.pop()

    gen_move_set = set(generated_moves)
    act_move_set = set(actual_moves)

    missing_moves = act_move_set.difference(gen_move_set)
    extra_moves = gen_move_set.difference(act_move_set)
    shared_moves = act_move_set.intersection(gen_move_set)

    missing_results = {
        move: actual_move_perfts[move] for move in missing_moves}
    extra_results = {
        move: generated_move_perfts[move] for move in extra_moves}
    shared_results = {
        move: generated_move_perfts[uci] - actual_move_perfts[uci] for move in shared_moves}

    return {
        "shared": shared_results,
        "missing": missing_results,
        "illegal": extra_results,
    }


# Error detection
MAX_DEPTH = 8


def main():
    results = move_diffs(board, perft_depth)
    no_errors = True

    if len(results["illegal"]) > 0:
        print("\n--- Illegal moves found ---")
        print("FEN: " + board.fen())
        print("Moves: " + json.dumps(results["shared"]))
        no_errors = False

    if len(results["missing"]) > 0:
        print("\n--- Missing moves found ---")
        print("FEN: " + board.fen())
        print("Moves: " + json.dumps(results["missing"]))
        no_errors = False

    discrepancies: dict[str, any] = {key: value for key,
                                     value in results["shared"].items() if value != 0}

    if len(discrepancies) > 0:
        print("\n--- Discrepancies found ---")

        # TODO: For each discrepancy, play the move, get the diffs, keep a running
        # TODO: total of extra / missing moves, and continue until the total equals
        # TODO: the discrepancy amount.

        for discrepancy in discrepancies.keys():
            print("Checking " + discrepancy + ":")
            board.push(chess.Move.from_uci(discrepancy))
            results = move_diffs(board, perft_depth - 1)

            if len(results["illegal"]) > 0:
                print("ILLEGAL FOUND")
                print(results["illegal"])

            if len(results["missing"]) > 0:
                print("MISSING FOUND")
                print(results["missing"])

            board.pop()

        print("Discrepancies: " + json.dumps(discrepancies))
        no_errors = False

    if no_errors:
        print("No errors found.")


if __name__ == '__main__':
    main()
