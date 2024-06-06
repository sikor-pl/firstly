import 'package:flutter/material.dart';

void main() => runApp(TicTacToeApp());

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TicTacToePage(),
    );
  }
}

class TicTacToePage extends StatefulWidget {
  @override
  _TicTacToePageState createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  List<List<String?>> board;
  String currentPlayer;
  List<Move> movesX;
  List<Move> movesO;
  List<List<int>> winningCombination;

  _TicTacToePageState()
      : board = List.generate(3, (_) => List.filled(3, null)),
        currentPlayer = 'X',
        movesX = [],
        movesO = [],
        winningCombination = [];

  void _resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, null));
      currentPlayer = 'X';
      movesX.clear();
      movesO.clear();
      winningCombination = [];
    });
  }

  void _makeMove(int row, int col) {
    if (board[row][col] != null || winningCombination.isNotEmpty) return;

    setState(() {
      if (currentPlayer == 'X' && movesX.length == 3) {
        final oldestMove = movesX.removeAt(0);
        board[oldestMove.row][oldestMove.col] = null;
      } else if (currentPlayer == 'O' && movesO.length == 3) {
        final oldestMove = movesO.removeAt(0);
        board[oldestMove.row][oldestMove.col] = null;
      }

      board[row][col] = currentPlayer;
      if (currentPlayer == 'X') {
        movesX.add(Move(row, col, currentPlayer));
      } else {
        movesO.add(Move(row, col, currentPlayer));
      }

      if (_checkWinner(row, col, currentPlayer)) {
        _showWinnerDialog();
      } else {
        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      }
    });
  }

  bool _checkWinner(int row, int col, String player) {
    // Check row
    if (board[row].every((cell) => cell == player)) {
      winningCombination = List.generate(3, (index) => [row, index]);
      return true;
    }

    // Check column
    if (board.every((r) => r[col] == player)) {
      winningCombination = List.generate(3, (index) => [index, col]);
      return true;
    }

    // Check diagonal
    if (row == col &&
        List.generate(3, (index) => board[index][index])
            .every((cell) => cell == player)) {
      winningCombination = List.generate(3, (index) => [index, index]);
      return true;
    }

    // Check anti-diagonal
    if (row + col == 2 &&
        List.generate(3, (index) => board[index][2 - index])
            .every((cell) => cell == player)) {
      winningCombination = List.generate(3, (index) => [index, 2 - index]);
      return true;
    }

    return false;
  }

  void _showWinnerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Gracz $currentPlayer wygrywa!'),
        content: Text('Liczba ruchów: ${movesX.length + movesO.length + 1}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: Text('Nowa gra'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kółko i krzyżyk'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (row) {
              return Expanded(
                child: Row(
                  children: List.generate(3, (col) {
                    bool isOldestX = currentPlayer == 'X' &&
                        movesX.length == 3 &&
                        movesX.first.row == row &&
                        movesX.first.col == col;
                    bool isOldestO = currentPlayer == 'O' &&
                        movesO.length == 3 &&
                        movesO.first.row == row &&
                        movesO.first.col == col;
                    bool isWinning = winningCombination
                        .any((pos) => pos[0] == row && pos[1] == col);
                    return Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          margin: EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isWinning
                                  ? Colors.green
                                  : board[row][col] != null
                                      ? (isOldestX || isOldestO)
                                          ? Colors.red
                                          : Colors.blue
                                      : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              board[row][col] != null ? board[row][col]! : '',
                              style: TextStyle(fontSize: 32.0),
                            ),
                            onPressed: () => _makeMove(row, col),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class Move {
  final int row;
  final int col;
  final String player;

  Move(this.row, this.col, this.player);
}
