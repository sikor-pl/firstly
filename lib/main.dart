import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

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
  int winCondition;
  int maxMovesBeforeDisappear;
  bool vsCPU;
  bool cpuFirst;

  _TicTacToePageState()
      : boardSize = 3,
        winCondition = 3,
        maxMovesBeforeDisappear = 3,
        board = List.generate(3, (_) => List.filled(3, null)),
        currentPlayer = 'X',
        movesX = [],
        movesO = [],
        winningCombination = [],
        moves = 0,
        vsCPU = false,
        cpuFirst = false;

  void _resetGame() {
    setState(() {
      board = List.generate(boardSize, (_) => List.filled(boardSize, null));
      currentPlayer = 'X';
      movesX.clear();
      movesO.clear();
      winningCombination = [];
      moves = 0;
      if (vsCPU && cpuFirst) {
        _makeCPUMove();
      }
    });
  }

  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int tempBoardSize = boardSize;
        int tempWinCondition = winCondition;
        int tempMaxMovesBeforeDisappear = maxMovesBeforeDisappear;
        bool tempVsCPU = vsCPU;
        bool tempCpuFirst = cpuFirst;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Ustawienia'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: tempBoardSize,
                    items: [3, 4, 5].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value x $value'),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        tempBoardSize = newValue!;
                        if (tempBoardSize == 3) {
                          tempWinCondition = 3;
                          tempMaxMovesBeforeDisappear = 3;
                        } else if (tempBoardSize == 4) {
                          if (tempWinCondition > 4) tempWinCondition = 4;
                          if (tempMaxMovesBeforeDisappear > 6)
                            tempMaxMovesBeforeDisappear = 6;
                        } else if (tempBoardSize == 5) {
                          if (tempWinCondition > 5) tempWinCondition = 5;
                          if (tempMaxMovesBeforeDisappear > 8)
                            tempMaxMovesBeforeDisappear = 8;
                        }
                      });
                    },
                  ),
                  if (tempBoardSize > 3)
                    DropdownButton<int>(
                      value: tempWinCondition,
                      items:
                          List.generate(tempBoardSize - 2, (index) => index + 3)
                              .map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value w rzędzie'),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          tempWinCondition = newValue!;
                        });
                      },
                    ),
                  if (tempBoardSize > 3)
                    DropdownButton<int>(
                      value: tempMaxMovesBeforeDisappear,
                      items: List.generate(
                              tempBoardSize * 2 - 2, (index) => index + 3)
                          .map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value ruchów do znikania'),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          tempMaxMovesBeforeDisappear = newValue!;
                        });
                      },
                    ),
                  Row(
                    children: [
                      Text('Tryb gry:'),
                      Switch(
                        value: tempVsCPU,
                        onChanged: (newValue) {
                          setState(() {
                            tempVsCPU = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                  if (tempVsCPU)
                    Row(
                      children: [
                        Text('CPU zaczyna:'),
                        Switch(
                          value: tempCpuFirst,
                          onChanged: (newValue) {
                            setState(() {
                              tempCpuFirst = newValue;
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
                    setState(() {
                      boardSize = tempBoardSize;
                      winCondition = tempWinCondition;
                      maxMovesBeforeDisappear = tempMaxMovesBeforeDisappear;
                      vsCPU = tempVsCPU;
                      cpuFirst = tempCpuFirst;
                      _resetGame();
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Zapisz'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Anuluj'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _makeMove(int row, int col) {
    if (board[row][col] != null || winningCombination.isNotEmpty) return;

    setState(() {
      if (currentPlayer == 'X' && movesX.length == maxMovesBeforeDisappear) {
        final oldestMove = movesX.removeAt(0);
        board[oldestMove.row][oldestMove.col] = null;
      } else if (currentPlayer == 'O' &&
          movesO.length == maxMovesBeforeDisappear) {
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
        if (vsCPU && currentPlayer == 'O') {
          _makeCPUMove();
        }
      }
    });
  }

  bool _checkWinner(int row, int col, String player) {
    int count = 0;

    // Check row
    for (int i = 0; i < boardSize; i++) {
      if (board[row][i] == player) {
        count++;
        if (count == winCondition) {
          winningCombination =
              List.generate(winCondition, (index) => [row, i - index]);
          return true;
        }
      } else {
        count = 0;
      }
    }

    // Check column
    count = 0;
    for (int i = 0; i < boardSize; i++) {
      if (board[i][col] == player) {
        count++;
        if (count == winCondition) {
          winningCombination =
              List.generate(winCondition, (index) => [i - index, col]);
          return true;
        }
      } else {
        count = 0;
      }
    }

    // Check diagonal
    count = 0;
    for (int i = 0; i < boardSize; i++) {
      int r = row - col + i;
      if (r >= 0 && r < boardSize && board[r][i] == player) {
        count++;
        if (count == winCondition) {
          winningCombination =
              List.generate(winCondition, (index) => [r - index, i - index]);
          return true;
        }
      } else {
        count = 0;
      }
    }

    // Check anti-diagonal
    count = 0;
    for (int i = 0; i < boardSize; i++) {
      int r = row + col - i;
      if (r >= 0 && r < boardSize && board[r][i] == player) {
        count++;
        if (count == winCondition) {
          winningCombination =
              List.generate(winCondition, (index) => [r - index, i + index]);
          return true;
        }
      } else {
        count = 0;
      }
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

  void _makeCPUMove() {
    Future.delayed(Duration(seconds: 1), () {
      if (winningCombination.isNotEmpty) return;

      int bestScore = -1000;
      int moveRow = -1;
      int moveCol = -1;

      for (int i = 0; i < boardSize; i++) {
        for (int j = 0; j < boardSize; j++) {
          if (board[i][j] == null) {
            board[i][j] = 'O';
            int score = _minimax(board, 0, false);
            board[i][j] = null;
            if (score > bestScore) {
              bestScore = score;
              moveRow = i;
              moveCol = j;
            }
          }
        }
      }

      _makeMove(moveRow, moveCol);
    });
  }

  int _minimax(List<List<String?>> board, int depth, bool isMaximizing) {
    if (_checkWinnerHelper('O')) return 10 - depth;
    if (_checkWinnerHelper('X')) return depth - 10;
    if (board.every((row) => row.every((cell) => cell != null))) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < boardSize; i++) {
        for (int j = 0; j < boardSize; j++) {
          if (board[i][j] == null) {
            board[i][j] = 'O';
            int score = _minimax(board, depth + 1, false);
            board[i][j] = null;
            bestScore = max(score, bestScore);
          }
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < boardSize; i++) {
        for (int j = 0; j < boardSize; j++) {
          if (board[i][j] == null) {
            board[i][j] = 'X';
            int score = _minimax(board, depth + 1, true);
            board[i][j] = null;
            bestScore = min(score, bestScore);
          }
        }
      }
      return bestScore;
    }
  }

  bool _checkWinnerHelper(String player) {
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        if (board[i][j] == player &&
            ((i + winCondition <= boardSize &&
                    List.generate(winCondition, (index) => board[i + index][j])
                        .every((cell) => cell == player)) ||
                (j + winCondition <= boardSize &&
                    List.generate(winCondition, (index) => board[i][j + index])
                        .every((cell) => cell == player)) ||
                (i + winCondition <= boardSize &&
                    j + winCondition <= boardSize &&
                    List.generate(
                            winCondition, (index) => board[i + index][j + index])
                        .every((cell) => cell == player)) ||
                (i + winCondition <= boardSize &&
                    j - winCondition + 1 >= 0 &&
                    List.generate(winCondition,
                            (index) => board[i + index][j - index])
                        .every((cell) => cell == player)))) {
          return true;
        }
      }
    }
    return false;
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
            onPressed: _openSettingsDialog,
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
                              movesX.length == maxMovesBeforeDisappear &&
                              movesX.first.row == row &&
                              movesX.first.col == col;
                          bool isOldestO = currentPlayer == 'O' &&
                              movesO.length == maxMovesBeforeDisappear &&
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
