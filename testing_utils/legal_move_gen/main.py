import chess

board = chess.Board("8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1")

legal_moves = list(board.legal_moves)

print('[')
for move in legal_moves:
    capture = 0b0100 if board.is_capture(move) else 0

    is_promotion = move.promotion != None
    promotion = (0b1000 | move.promotion - 1) if is_promotion else 0

    special = 0

    if not is_promotion:
        if board.piece_at(move.from_square) == chess.PAWN and chess.square_distance(move.from_square, move.to_square) == 2:
            # Double push
            special = 0b01
        elif board.is_queenside_castling(move):
            special = 0b10
        elif board.is_kingside_castling(move):
            special = 0b11
        elif board.is_en_passant(move):
            special = 0b01

    flags = capture | promotion | special

    move = str(move)
    source = move[0] + move[1]
    target = move[2] + move[3]

    print(
        f'  move.new(square.{source.upper()}, square.{target.upper()}, {flags}),')
print('] |> list.sort(int.compare)')
