import 'package:flutter/material.dart';
import 'package:lights_out/components/board_state.dart';
import 'package:lights_out/components/tile.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  static const String id = 'game_screen';

  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ChangeNotifierProvider(
          create: (context) => BoardState(),
          child: GridView.count(
            crossAxisCount: 5,
            children: List.generate(
                25,
                (index) => Consumer<BoardState>(
                      builder: (context, boardState, child) {
                        return Tile(
                            x: index ~/ 5,
                            y: index % 5,
                            boardState: boardState);
                      },
                    ),
                growable: false),
          ),
        ),
      ),
    );
  }
}
