import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as ch;
import 'package:google_fonts/google_fonts.dart';

class GameScreen extends StatefulWidget {
  final bool vsBot;

  const GameScreen({super.key, required this.vsBot});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ch.Chess game;
  String? selectedSquare;
  List<String> legalTargets = [];
  bool whiteToMove = true;
  String status = 'White to move';

  String _pieceSymbol(ch.Piece piece) {
    const white = {
      ch.PieceType.KING: '♔',
      ch.PieceType.QUEEN: '♕',
      ch.PieceType.ROOK: '♖',
      ch.PieceType.BISHOP: '♗',
      ch.PieceType.KNIGHT: '♘',
      ch.PieceType.PAWN: '♙',
    };
    const black = {
      ch.PieceType.KING: '♚',
      ch.PieceType.QUEEN: '♛',
      ch.PieceType.ROOK: '♜',
      ch.PieceType.BISHOP: '♝',
      ch.PieceType.KNIGHT: '♞',
      ch.PieceType.PAWN: '♟',
    };
    return piece.color == ch.Color.WHITE
        ? (white[piece.type] ?? '?')
        : (black[piece.type] ?? '?');
  }

  @override
  void initState() {
    super.initState();
    game = ch.Chess();
  }

  void _onSquareTap(String square) {
    if (game.game_over) return;

    final piece = game.get(square);

    if (selectedSquare != null) {
      final move = <String, String>{
        'from': selectedSquare!,
        'to': square,
      };

      if (_isPromotionMove(selectedSquare!, square)) {
        move['promotion'] = 'q';
      }

      final success = game.move(move);

      if (success) {
        setState(() {
          selectedSquare = null;
          legalTargets = [];
          whiteToMove = game.turn == ch.Color.WHITE;
          _updateStatus();
        });

        if (widget.vsBot && !game.game_over && game.turn == ch.Color.BLACK) {
          Future.delayed(const Duration(milliseconds: 400), _makeBotMove);
        }
        return;
      }

      if (piece != null && piece.color == game.turn) {
        _selectSquare(square);
        return;
      }

      setState(() {
        selectedSquare = null;
        legalTargets = [];
      });
      return;
    }

    if (piece != null && piece.color == game.turn) {
      _selectSquare(square);
    }
  }

  void _selectSquare(String square) {
    final moves = game.generate_moves({'square': square});
    setState(() {
      selectedSquare = square;
      legalTargets = moves.map((m) => m.toAlgebraic).toList();
    });
  }

  bool _isPromotionMove(String from, String to) {
    final piece = game.get(from);
    if (piece == null || piece.type != ch.PieceType.PAWN) return false;
    final rank = to[1];
    return (piece.color == ch.Color.WHITE && rank == '8') ||
        (piece.color == ch.Color.BLACK && rank == '1');
  }

  void _makeBotMove() {
    if (game.game_over) return;
    final moves = game.generate_moves();
    if (moves.isEmpty) return;

    moves.shuffle();
    game.move(moves.first);

    setState(() {
      whiteToMove = game.turn == ch.Color.WHITE;
      _updateStatus();
    });
  }

  void _updateStatus() {
    if (game.in_checkmate) {
      status = game.turn == ch.Color.WHITE
          ? 'Black wins by checkmate!'
          : 'White wins by checkmate!';
    } else if (game.in_stalemate) {
      status = 'Draw by stalemate';
    } else if (game.in_draw) {
      status = 'Draw';
    } else if (game.in_check) {
      status = whiteToMove ? 'White is in check' : 'Black is in check';
    } else {
      status = whiteToMove ? 'White to move' : 'Black to move';
    }
  }

  void _resetGame() {
    setState(() {
      game = ch.Chess();
      selectedSquare = null;
      legalTargets = [];
      whiteToMove = true;
      status = 'White to move';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vsBot ? 'vs Bot' : 'Local Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'New Game',
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: theme.colorScheme.primary.withOpacity(0.08),
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AspectRatio(
              aspectRatio: 1,
              child: _buildBoard(),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(
              widget.vsBot ? 'Bot plays randomly for now' : 'Pass & play',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    const lightSquare = Color(0xFFEEEED2);
    const darkSquare = Color(0xFF769656);
    const selectedColor = Color(0xFFCDD26A);
    const legalColor = Color(0x994A90A4);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: 64,
        itemBuilder: (context, index) {
          final rank = 7 - (index ~/ 8);
          final file = index % 8;
          final square = '${String.fromCharCode(97 + file)}${rank + 1}';
          final isLight = (rank + file) % 2 == 1;
          final piece = game.get(square);
          final isSelected = selectedSquare == square;
          final isLegal = legalTargets.contains(square);

          Color squareColor = isLight ? lightSquare : darkSquare;
          if (isSelected) squareColor = selectedColor;

          return GestureDetector(
            onTap: () => _onSquareTap(square),
            child: Container(
              color: squareColor,
              child: Stack(
                children: [
                  if (isLegal)
                    Center(
                      child: Container(
                        width: piece != null ? 42 : 18,
                        height: piece != null ? 42 : 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: piece != null ? Colors.transparent : legalColor,
                          border: piece != null
                              ? Border.all(color: legalColor, width: 5)
                              : null,
                        ),
                      ),
                    ),
                  if (piece != null)
                    Center(
                      child: Text(
                        _pieceSymbol(piece),
                        style: TextStyle(
                          fontSize: 36,
                          height: 1,
                          color: piece.color == ch.Color.WHITE
                              ? Colors.white
                              : Colors.black87,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}