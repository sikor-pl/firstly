import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  int maxDepth;
  int cpuDifficulty; // 0 for easy, 1 for hard
  bool _isCPUMoving = false;
  bool _twoOldestMoves = false;

  List<GameState> gameStateHistory;

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
        vsCPU = true,
        cpuFirst = false,
        maxDepth = 5,
        cpuDifficulty = 1,
        gameStateHistory = [];

  void _resetGame() {
    setState(() {
      board = List.generate(boardSize, (_) => List.filled(boardSize, null));
      currentPlayer = cpuFirst ? 'O' : 'X';
      movesX.clear();
      movesO.clear();
      winningCombination = [];
      moves = 0;
      gameStateHistory.clear();
      if (vsCPU && cpuFirst) {
        _makeCPUMove();
      }
    });
  }

  void _saveGameState() {
    gameStateHistory.add(GameState(
      board: List.generate(boardSize, (i) => List.from(board[i])),
      movesX: List.from(movesX),
      movesO: List.from(movesO),
      currentPlayer: currentPlayer,
      moves: moves,
      winningCombination: List.from(winningCombination),
    ));
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
        int tempCpuDifficulty = cpuDifficulty;
        bool tempTwoOldestMoves = _twoOldestMoves;

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
                          tempWinCondition = 3;
                          tempMaxMovesBeforeDisappear = 3;
                        } else if (tempBoardSize == 5) {
                          tempWinCondition = 4;
                          tempMaxMovesBeforeDisappear = 6;
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
                      Text('Gra z CPU:'),
                      Spacer(),
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
                        Spacer(),
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
                  if (tempVsCPU)
                    Row(
                      children: [
                        Text('Poziom trudności CPU:'),
                        Spacer(),
                        DropdownButton<int>(
                          value: tempCpuDifficulty,
                          items: [
                            DropdownMenuItem<int>(
                              value: 0,
                              child: Text('Łatwy'),
                            ),
                            DropdownMenuItem<int>(
                              value: 1,
                              child: Text('Trudny'),
                            ),
                            DropdownMenuItem<int>(
                              value: 2,
                              child: Text('Extra!'),
                            ),
                          ],
                          onChanged: (newValue) {
                            setState(() {
                              tempCpuDifficulty = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      Text('Więcej podpowiedzi:'),
                      Spacer(),
                      Switch(
                        value: tempTwoOldestMoves,
                        onChanged: (newValue) {
                          setState(() {
                            tempTwoOldestMoves = newValue;
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
                      cpuDifficulty = tempCpuDifficulty;
                      _twoOldestMoves = tempTwoOldestMoves;
                      if (boardSize == 5) {
                        if (cpuDifficulty == 0) {
                          maxDepth = 3; // Easy mode
                        } else if (cpuDifficulty == 1) {
                          maxDepth = 4; // Hard mode
                        } else {
                          maxDepth = 5; // Extra mode
                        }
                      } else {
                        if (cpuDifficulty == 0) {
                          maxDepth = 3; // Easy mode
                        } else if (cpuDifficulty == 1) {
                          maxDepth = 5; // Hard mode
                        } else {
                          maxDepth = 7; // Extra mode
                        }
                      }
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

    _saveGameState();

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

  void _undoMove() {
    if (gameStateHistory.isEmpty) return;

    var previousState = gameStateHistory.removeLast();

    if (vsCPU) {
      previousState = gameStateHistory.removeLast();
    }

    setState(() {
      board = previousState.board;
      movesX = previousState.movesX;
      movesO = previousState.movesO;
      currentPlayer = previousState.currentPlayer;
      moves = previousState.moves;
      winningCombination = previousState.winningCombination;
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
              Future.delayed(Duration(seconds: 2), () {
                _resetGame(); // Odczekaj 2 sekundy, a następnie wywołaj _resetGame
              });
            },
            child: Text('Nowa gra'),
          ),
        ],
      ),
    );
  }

  void _makeCPUMove() {
    setState(() {
      _isCPUMoving = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      if (winningCombination.isNotEmpty) return;

      int bestScore = -1000;
      List<Map<String, int>> bestMoves = [];
      print(board);

      for (int i = 0; i < boardSize; i++) {
        for (int j = 0; j < boardSize; j++) {
          if (board[i][j] == null) {
            // Sprawdzenie znikającego ruchu
            // _removeOldestMove(board);

            board[i][j] = 'O';
            int score = _minimax(board, 0, false);
            board[i][j] = null;
            if ((score > bestScore) && (board[i][j] == null)) {
              bestScore = score;
              bestMoves = [
                {'row': i, 'col': j, 'score': score}
              ];
            } else if ((score == bestScore) && (board[i][j] == null)) {
              bestMoves.add({'row': i, 'col': j, 'score': score});
            }
          }
        }
      }

      // Sortowanie ruchów od najwyższego do najniższego score
      bestMoves.sort((a, b) => b['score']!.compareTo(a['score']!));

      // Wybór ruchów zależnie od poziomu trudności
      List<Map<String, int>> chosenMoves;
      if (cpuDifficulty > 0) {
        // Poziom trudny: wybieraj losowo z ruchów o najwyższym score
        int highestScore = bestMoves.first['score']!;
        chosenMoves =
            bestMoves.where((move) => move['score'] == highestScore).toList();
      } else {
        // Poziom łatwy: wybieraj losowo z ruchów o dwóch najwyższych score
        Set<int> topScores =
            bestMoves.map((move) => move['score']!).toSet().take(2).toSet();
        chosenMoves = bestMoves
            .where((move) => topScores.contains(move['score']))
            .toList();
      }

      print(bestMoves);
      var random = Random();
      var chosenMove = chosenMoves[random.nextInt(chosenMoves.length)];

      _makeMove(chosenMove['row']!, chosenMove['col']!);

      setState(() {
        _isCPUMoving = false;
      });
    });
  }

  void _removeOldestMove(List<List<String?>> board) {
    if (currentPlayer == 'X' && movesX.length == maxMovesBeforeDisappear) {
      final oldestMove = movesX.removeAt(0);
      board[oldestMove.row][oldestMove.col] = null;
    } else if (currentPlayer == 'O' &&
        movesO.length == maxMovesBeforeDisappear) {
      final oldestMove = movesO.removeAt(0);
      board[oldestMove.row][oldestMove.col] = null;
    }
  }

  int _minimax(List<List<String?>> board, int depth, bool isMaximizing) {
    if (_checkWinnerHelper('O')) return 10 - depth;
    if (_checkWinnerHelper('X')) return depth - 10;
    if (board.every((row) => row.every((cell) => cell != null)) ||
        depth >= maxDepth) return 0;

    // Uwzględnianie znikających ruchów
    _removeOldestMove(board);

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
            icon: Icon(Icons.undo),
            onPressed: _undoMove,
          ),
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
      body: Stack(
        // Używamy Stack, aby dodać spinner jako overlay
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${currentPlayer == 'O' && vsCPU ? 'Ruch komputera' : 'Ruch gracza'}: $currentPlayer',
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
                              bool isOldestX =
                                  movesX.length == maxMovesBeforeDisappear &&
                                      movesX.first.row == row &&
                                      movesX.first.col == col;
                              bool isSecoundOldestX = !isOldestX &&
                                  ((movesX.length >
                                              maxMovesBeforeDisappear - 1 &&
                                          movesX.elementAt(1).row == row &&
                                          movesX.elementAt(1).col == col) ||
                                      (movesX.length >
                                              maxMovesBeforeDisappear - 2 &&
                                          movesX.elementAt(0).row == row &&
                                          movesX.elementAt(0).col == col));
                              bool isOldestO =
                                  movesO.length == maxMovesBeforeDisappear &&
                                      movesO.first.row == row &&
                                      movesO.first.col == col;
                              bool isSecoundOldestO = !isOldestO &&
                                  ((movesO.length >
                                              maxMovesBeforeDisappear - 1 &&
                                          movesO.elementAt(1).row == row &&
                                          movesO.elementAt(1).col == col) ||
                                      (movesO.length >
                                              maxMovesBeforeDisappear - 2 &&
                                          movesO.elementAt(0).row == row &&
                                          movesO.elementAt(0).col == col));
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
                                            : board[row][col] == null
                                                ? Colors.grey
                                                : (_twoOldestMoves &&
                                                        (isSecoundOldestX ||
                                                            isSecoundOldestO))
                                                    ? Colors.red
                                                        .withOpacity(0.5)
                                                    : ((_twoOldestMoves &&
                                                                (isOldestX ||
                                                                    isOldestO) ||
                                                            (currentPlayer ==
                                                                    'X' &&
                                                                isOldestX) ||
                                                            (currentPlayer ==
                                                                    'O' &&
                                                                isOldestO)))
                                                        ? Colors.red
                                                        : Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      child: Text(
                                        board[row][col] != null
                                            ? board[row][col]!
                                            : '',
                                        style: TextStyle(fontSize: 32.0),
                                      ),
                                      onPressed: () {
                                        if (!vsCPU ||
                                            (vsCPU && currentPlayer == 'X')) {
                                          _makeMove(row, col);
                                        }
                                      },
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
          if (_isCPUMoving) // Dodajemy spinner jako overlay, jeśli _isCPUMoving jest true
            Container(
              color: Colors.black.withOpacity(0.1),
              child: Center(
                child: SpinKitFadingCube(
                  color: Colors.white,
                  size: 50.0,
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

class GameState {
  final List<List<String?>> board;
  final List<Move> movesX;
  final List<Move> movesO;
  final String currentPlayer;
  final int moves;
  final List<List<int>> winningCombination;

  GameState({
    required this.board,
    required this.movesX,
    required this.movesO,
    required this.currentPlayer,
    required this.moves,
    required this.winningCombination,
  });
}
