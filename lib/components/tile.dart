import 'package:flutter/material.dart';

import 'board_state.dart';

class Tile extends StatefulWidget {
  const Tile(
      {required this.x, required this.y, required this.boardState, Key? key})
      : super(key: key);

  final int x;
  final int y;
  final BoardState boardState;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  bool on = false;

  @override
  Widget build(BuildContext context) {
    on = widget.boardState.state[widget.x][widget.y];

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        backgroundColor: on ? Colors.blue : Colors.white,
      ),
      child: Text(
        "${widget.x}, ${widget.y}",
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      onPressed: () {
        widget.boardState.toggle(widget.x, widget.y);
      },
    );
  }
}
