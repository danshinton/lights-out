import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../constants.dart';
import '../components/tile.dart';
import '../models/board_model.dart';

const winMessage = "You Won!"; // If the user solves the puzzle on their own
const solveMessage = "Solved!"; // If the user asked the app to solve the puzzle
const solveButtonText = "Solve";
const solveButtonTextWhenSolving = "Solving...";

/// The main screen for the Lights Out application
class GameScreen extends StatefulWidget {
  /// This id is used for named routing
  static const String id = 'game_screen';

  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final BoardModel _model;

  final ConfettiController _confetti = ConfettiController(
    duration: const Duration(seconds: 5),
  );

  var _solveMessage = winMessage;
  var _solveButtonText = solveButtonText;

  @override
  void initState() {
    super.initState();
    _model = BoardModel(solvedCallback: _solveCallback);
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  /// This method will be called when the model is in a solved state
  void _solveCallback() {
    setState(() {
      // Reset the button text just in case this was solved by the app
      _solveButtonText = solveButtonText;
    });

    // Display the confetti animation
    _confetti.play();
  }

  /// The `onPressed` action for the solve button.
  void _doSolve() {
    // Get the solution
    List<Tuple2<int, int>>? solution = _model.getSolution();

    // If one was found,
    if (solution != null) {
      setState(() {
        _solveButtonText = solveButtonTextWhenSolving;
        _solveMessage = solveMessage;
      });

      _model.applySolution(solution);
    }
  }

  /// the `onPressed` action for the new game button
  void _doNewGame() {
    // Put text back to default
    setState(() {
      _solveMessage = winMessage;
      _solveButtonText = solveButtonText;
    });

    // Stop the confetti
    _confetti.stop();

    // Reset the model
    _model.reset();
  }

  @override
  Widget build(BuildContext context) {
    int size = _model.size();
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: SafeArea(
        child: ChangeNotifierProvider(
          create: (context) => _model,
          child: Stack(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 8.0,
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.lightbulb,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        appTitle,
                        style: headerTextStyle,
                      ),
                    ],
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: size,
                    padding: const EdgeInsets.all(5.0),
                    children: List.generate(
                        pow(size, 2) as int,
                        (index) => Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Consumer<BoardModel>(
                                  builder: (context, boardModel, child) => Tile(
                                        x: index ~/ size,
                                        y: index % size,
                                        model: boardModel,
                                      )),
                            ),
                        growable: false),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Consumer<BoardModel>(
                          builder: (context, boardModel, child) {
                            return Text(
                              "Moves: ${boardModel.moveCount()}",
                              style: bodyTextStyle,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Consumer<BoardModel>(
                          builder: (context, boardModel, child) {
                            return Visibility(
                              visible: boardModel.solved(),
                              child: Text(
                                _solveMessage,
                                style: bodyTextStyle,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 150.0,
                          child: Consumer<BoardModel>(
                            builder: (context, boardModel, child) {
                              return ElevatedButton(
                                style: buttonStyle,
                                onPressed:
                                    boardModel.solving() ? null : _doNewGame,
                                child: const Text("New Game"),
                              );
                            },
                          ),
                        ),
                        Visibility(
                          visible: size == defaultBoardSize,
                          child: SizedBox(
                            width: 150.0,
                            child: Consumer<BoardModel>(
                              builder: (context, boardModel, child) {
                                return ElevatedButton(
                                  style: buttonStyle,
                                  onPressed: _model.solved() ? null : _doSolve,
                                  child: Text(_solveButtonText),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
