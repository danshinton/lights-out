import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../components/tile.dart';
import '../models/board_model.dart';

class GameScreen extends StatefulWidget {
  static const String id = 'game_screen';

  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  BoardModel model = BoardModel();

  @override
  Widget build(BuildContext context) {
    int size = model.size();

    return Scaffold(
      body: SafeArea(
        child: ChangeNotifierProvider(
          create: (context) => model,
          child: Column(
            children: [
              Consumer<BoardModel>(
                builder: (context, boardModel, child) {
                  return GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: size,
                    children: List.generate(
                        pow(size, 2) as int,
                        (index) => Tile(
                              x: index ~/ size,
                              y: index % size,
                              model: boardModel,
                            ),
                        growable: false),
                  );
                },
              ),
              Consumer<BoardModel>(
                builder: (context, boardModel, child) {
                  return Text("Moves: ${boardModel.moveCount()}");
                },
              ),
              Consumer<BoardModel>(
                builder: (context, boardModel, child) {
                  return Visibility(
                    visible: boardModel.solved(),
                    child: const Text("You win!"),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  model.reset();
                },
                child: const Text("Reset"),
              ),
              Visibility(
                visible: size == 5,
                child: ElevatedButton(
                  onPressed: () {
                    List<Tuple2<int, int>>? solution = model.getSolution();

                    if (solution != null) {
                      model.applySolution(solution);
                    }
                  },
                  child: const Text("Solve"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
