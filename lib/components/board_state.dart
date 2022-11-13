import 'package:flutter/cupertino.dart';

class BoardState extends ChangeNotifier {
  final state = List.generate(5, (x) => List.filled(5, false), growable: false);

  var move = 0;

  void toggle(int x, int y) {
    state[x][y] = !state[x][y];

    if (x != 0) {
      state[x - 1][y] = !state[x - 1][y];
    }

    if (x != 4) {
      state[x + 1][y] = !state[x + 1][y];
    }

    if (y != 0) {
      state[x][y - 1] = !state[x][y - 1];
    }

    if (y != 4) {
      state[x][y + 1] = !state[x][y + 1];
    }

    ++move;

    notifyListeners();
  }
}
