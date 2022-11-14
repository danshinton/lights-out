import 'package:flutter/material.dart';
import 'package:lights_out/models/board_model.dart';

class Tile extends StatefulWidget {
  const Tile({required this.x, required this.y, required this.model, Key? key})
      : super(key: key);

  final int x;
  final int y;
  final BoardModel model;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  bool isLit() {
    return widget.model.isLit(widget.x, widget.y);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        backgroundColor: isLit() ? Colors.blue : Colors.white,
      ),
      child: Text(
        "${widget.x}, ${widget.y}",
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      onPressed: () {
        widget.model.toggle(widget.x, widget.y);
      },
    );
  }
}
