import 'package:flutter/material.dart';
import 'package:lights_out/screens/game_screen.dart';

void main() {
  runApp(const LightsOut());
}

class LightsOut extends StatelessWidget {
  const LightsOut({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lights Out',
      routes: {
        '/': (context) => const GameScreen(),
      },
    );
  }
}
