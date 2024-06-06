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
  int moves;
  int boardSize;
  int movesLimit;

  _TicTacToePageState()
      : boardSize = 3,
        movesLimit = 3,
        board = List.generate(3, (_) => List.filled(3, null)),
        currentPlayer = 'X',
        movesX = [],
        movesO = [],
        winningCombination = [],
        moves = 0;

  void _resetGame() {
    setState(() {
      board = List.generate(boardSize, (_) => List.filled(boardSize, null));
      currentPlayer = 'X';
      movesX.clear();
      movesO.clear();
      winningCombination = [];
      moves = 0;
    });
  }

  void _makeMove(int row, int col) {
    if (board[row][col] != null || winningCombination.isNotEmpty) return;

    setState(() {
      if (currentPlayer == 'X' && movesX.length == movesLimit) {
        final oldestMove = movesX.removeAt(0);
        board[oldestMove.row][oldestMove.col] = null;
      } else if (currentPlayer == 'O' && movesO.length == movesLimit) {
        final oldestMove = movesO.removeAt(0);
        board[oldestMove.row][oldestMove.col] = null;
      }

      board[row][col] = currentPlayer;
      if (currentPlayer == 'X') {
        movesX.add(Move(row, col, currentPlayer));
        moves++;
      } else {
        movesO.add(Move(row, col, currentPlayer));
        moves++;
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
      winningCombination = List.generate(boardSize, (index) => [row, index]);
      return true;
    }

    // Check column
    if (board.every((r) => r[col] == player)) {
      winningCombination = List.generate(boardSize, (index) => [index, col]);
      return true;
    }

    // Check diagonal
    if (row == col &&
        List.generate(boardSize, (index) => board[index][index])
            .every((cell) => cell == player)) {
      winningCombination = List.generate(boardSize, (index) => [index, index]);
      return true;
    }

    // Check anti-diagonal
    if (row + col == boardSize - 1 &&
        List.generate(boardSize, (index) => board[index][boardSize - 1 - index])
            .every((cell) => cell == player)) {
      winningCombination =
          List.generate(boardSize, (index) => [index, boardSize - 1 - index]);
      return true;
    }

    return false;
  }

  void _showWinnerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Gracz $currentPlayer wygrywa!'),
        content: Text('Liczba ruchów: $moves'),
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

  void _showSettingsDialog() {
    int tempBoardSize = boardSize;
    int tempMovesLimit = movesLimit;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ustawienia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text('Rozmiar planszy:'),
                  SizedBox(width: 10),
                  DropdownButton<int>(
                    value: tempBoardSize,
                    items: [3, 5, 7].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        tempBoardSize = newValue!;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Liczba ruchów:'),
                  SizedBox(width: 10),
                  DropdownButton<int>(
                    value: tempMovesLimit,
                    items: List.generate(tempBoardSize, (index) => index + 1)
                        .map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        tempMovesLimit = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  boardSize = tempBoardSize;
                  movesLimit = tempMovesLimit;
                  _resetGame();
                });
              },
              child: Text('Zastosuj'),
            ),
          ],
        );
      },
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
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Ruch gracza: $currentPlayer',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(boardSize, (row) {
                    return Expanded(
                      child: Row(
                        children: List.generate(boardSize, (col) {
                          bool isOldestX = currentPlayer == 'X' &&
                              movesX.length == movesLimit &&
                              movesX.first.row == row &&
                              movesX.first.col == col;
                          bool isOldestO = currentPlayer == 'O' &&
                              movesO.length == movesLimit &&
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
                                    board[row][col] != null
                                        ? board[row][col]!
                                        : '',
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
          ),
        ],
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
