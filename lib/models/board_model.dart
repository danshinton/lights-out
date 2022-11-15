import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';

import '../constants.dart';

/// Model object used to hold state for the lights out board.
///
/// This class implements [ChangeNotifier] because it is intended to be used in
/// conjunction with the `Provider` library to notify tiles when their state
/// has changed.
class BoardModel extends ChangeNotifier {
  final List<List<bool>> _state;

  final int _size;

  final Function? _solvedCallback;

  List<Tuple2<int, int>>? _initialSolution;

  bool _solving = false;

  bool _solved = false;

  int _move = 0;

  /// Create a new board model initialized to the default state.
  ///
  /// Please be aware that at the time of this writing, only 5x5 boards are
  /// supported for auto-solve. So if you choose a different size, the game
  /// will be playable, but not auto-solvable.
  BoardModel({int size = defaultBoardSize, Function? solvedCallback})
      : _size = size,
        _solvedCallback = solvedCallback,
        _state = List.generate(size, (index) => List.filled(size, false)) {
    _scramble();
  }

  /// Returns the size of the board.
  ///
  /// All boards are symmetric, so a size of `5` means the board is `5x5`.
  int size() {
    return _size;
  }

  /// Returns true of the tile at the specified coordinates is lit.
  bool isLit(int x, int y) {
    return _state[x][y];
  }

  /// Returns the number of moves executed for this board.
  int moveCount() {
    return _move;
  }

  /// Returns `true` if this board has been solved.
  bool solved() {
    return _solved;
  }

  /// Returns `true` if this board is in the process of being solved.
  bool solving() {
    return _solving;
  }

  /// This method is used when a solution is to be applied to the model.
  ///
  /// Takes a list of moves to make against the board with the intention of
  /// solving the puzzle. While a solution is being applied, the user will
  /// not be able to manipulate the puzzle.
  ///
  /// The solution is applied by running though moves as if the user made them.
  /// This animates the interface showing the user the moves being made.
  ///
  void applySolution(List<Tuple2<int, int>> solution) {
    _solving = true;

    // Create a queue of moves
    Queue<Tuple2<int, int>> moveQueue = Queue();
    moveQueue.addAll(solution);

    // Pop one off the queue and apply it ever 500 milliseconds until all
    // moves are exhausted.
    Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
      if (moveQueue.isNotEmpty) {
        Tuple2<int, int> move = moveQueue.removeFirst();
        _toggle(move.item1, move.item2);
      } else {
        t.cancel();
        _solving = false;
        notifyListeners();
      }
    });
  }

  /// Manipulate the app based on a move.
  ///
  /// This method triggers all the board changes that are the result of the
  /// given move.
  void toggle(int x, int y) {
    if (_solving) return;
    _toggle(x, y);
  }

  /// Manipulate the app based on a move.
  ///
  /// This method does all the housekeeping for keeping track of moves and
  /// determining if the game has been won.
  void _toggle(int x, int y) {
    if (_solved) return;

    // Invalidate the initial solution since a move was made
    _initialSolution = null;

    // Make the move
    _doToggle(x, y, _state);

    // Record the move
    ++_move;

    // Check for win
    _solved = _checkForWin();

    // If solved, trigger callback
    if (_solved && (_solvedCallback != null)) {
      _solvedCallback!();
    }

    // Tell everyone to update
    notifyListeners();
  }

  /// Manipulate the state based on a move.
  ///
  /// When you toggle a tile, the tiles above, below, left, and right are also
  /// toggled.
  void _doToggle(int x, int y, List<List<bool>> state) {
    // Toggle the requested tile
    state[x][y] = !state[x][y];

    // Toggle the tile above it
    if (x != 0) {
      state[x - 1][y] = !state[x - 1][y];
    }

    // Toggle the tile below it
    if (x != (_size - 1)) {
      state[x + 1][y] = !state[x + 1][y];
    }

    // Toggle the tile to the left
    if (y != 0) {
      state[x][y - 1] = !state[x][y - 1];
    }

    // Toggle the tile to the right
    if (y != (_size - 1)) {
      state[x][y + 1] = !state[x][y + 1];
    }
  }

  /// Returns `true` if all the lights have been turned off
  bool _checkForWin() {
    for (List<bool> i in _state) {
      for (bool j in i) {
        if (j) return false;
      }
    }

    return true;
  }

  /// Create a new solvable board configuration.
  void _scramble() {
    // Clear the state
    for (List<bool> i in _state) {
      i.fillRange(0, _size, false);
    }

    // Generate random moves making sure the same move isn't done twice in a row
    var rand = Random();
    int lights = pow(_size, 2) as int;
    int previous = -1;

    List<int> steps = List.generate(rand.nextInt(_size) + _size, (index) {
      int value = 0;

      do {
        value = rand.nextInt(lights);
      } while (value == previous);

      previous = value;
      return value;
    });

    // Iterate through the moves
    List<Tuple2<int, int>> moves = [];

    for (int step in steps) {
      int x = step ~/ _size;
      int y = step % _size;
      _doToggle(x, y, _state);
      moves.add(Tuple2(x, y));
    }

    // The initial solution is just our moves in reverse
    _initialSolution = List.from(moves.reversed);

    // Update the interface
    notifyListeners();
  }

  /// Determines a solution for the current board state.
  ///
  /// The code uses the "Light Chasing" algorithm to solve the board. Light
  /// chasing is not the most efficient, but it is a sure way to solve a board.
  ///
  /// When solved, the method returns the list of moves that should be made for
  /// this board configuration. If not solved, the method returns `null`.
  List<Tuple2<int, int>>? getSolution() {
    if (_initialSolution != null) {
      return _initialSolution;
    }

    // The code as of right now can only solve 5x5 boards. To solve any size
    // board we will need to do a light chasing test of where each first row
    // ends up or change the solver to use linear algebra.
    if (_size != 5) {
      return null;
    }

    // Copy the state so we can manipulate the board without changing anything
    List<List<bool>> board =
        List.generate(_size, (index) => [..._state[index]]);

    // The solution will be stores as a list of tuples
    List<Tuple2<int, int>> solution = [];

    int loopCount = 0;

    do {
      // Clear all the rows except the bottom row
      for (int x = 0; x < (_size - 1); ++x) {
        for (int y = 0; y < _size; ++y) {
          if (board[x][y]) {
            _doToggle(x + 1, y, board);
            solution.add(Tuple2(x + 1, y));
          }
        }
      }

      // Depending on the configuration of the bottom row, toggle tiles in the
      // first row that will propagate down to clear the bottom row.
      List<bool> lastRow = board[_size - 1];

      if (lastRow[0] && lastRow[1] && lastRow[2]) {
        // 1 1 1 0 0
        _doToggle(0, 1, board);
        solution.add(const Tuple2(0, 1));
      } else if (lastRow[0] && lastRow[1] && lastRow[3] && lastRow[4]) {
        // 1 1 0 1 1
        _doToggle(0, 2, board);
        solution.add(const Tuple2(0, 2));
      } else if (lastRow[0] && lastRow[2] && lastRow[3]) {
        // 1 0 1 1 0
        _doToggle(0, 4, board);
        solution.add(const Tuple2(0, 4));
      } else if (lastRow[0] && lastRow[4]) {
        // 1 0 0 0 1
        _doToggle(0, 0, board);
        _doToggle(0, 1, board);
        solution.add(const Tuple2(0, 0));
        solution.add(const Tuple2(0, 1));
      } else if (lastRow[1] && lastRow[2] && lastRow[4]) {
        // 0 1 1 0 1
        _doToggle(0, 0, board);
        solution.add(const Tuple2(0, 0));
      } else if (lastRow[1] && lastRow[3]) {
        // 0 1 0 1 0
        _doToggle(0, 0, board);
        _doToggle(0, 3, board);
        solution.add(const Tuple2(0, 0));
        solution.add(const Tuple2(0, 3));
      } else if (lastRow[2] && lastRow[3] && lastRow[4]) {
        // 0 0 1 1 1
        _doToggle(0, 3, board);
        solution.add(const Tuple2(0, 3));
      } else {
        // Looks like there is nothing more to do!
        return solution;
      }

      // We should be able to do this in two passes. If we are still looping
      // after two passes, then something is wrong.
      ++loopCount;
    } while (loopCount < 3);

    return null;
  }

  /// Resets the model to the default state.
  ///
  /// The default state for the model is game board with random but solvable
  /// tile configuration.
  void reset() {
    _solved = false;
    _move = 0;

    _scramble();
  }
}
