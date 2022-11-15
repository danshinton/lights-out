import 'package:flutter/material.dart';

import '../models/board_model.dart';

/// This widget represents a single tile for the Lights Out game.
class Tile extends StatefulWidget {
  /// Create a new Tile.
  ///
  /// The `x` and `y` coordinates of the tile must be supplied along with the
  /// board model. The state of the Tile is tied to that model and will update
  /// when the model updates via a provider notification.
  ///
  /// For the purposes of debugging, you can set `debug` to `true`. This will
  /// add the x and y coordinates to each tile for easy identification.
  const Tile(
      {required x, required y, required model, bool debug = false, Key? key})
      : _x = x,
        _y = y,
        _model = model,
        _debug = debug,
        super(key: key);

  final int _x;
  final int _y;
  final BoardModel _model;
  final bool _debug;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  /// Check the model to see if this tile is lit
  bool _isLit() {
    return widget._model.isLit(widget._x, widget._y);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const ContinuousRectangleBorder(),
        backgroundColor: _isLit() ? Colors.blue : Colors.white,
      ),
      child: Text(
        widget._debug ? "${widget._x}, ${widget._y}" : "",
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      onPressed: () {
        widget._model.toggle(widget._x, widget._y);
      },
    );
  }
}
