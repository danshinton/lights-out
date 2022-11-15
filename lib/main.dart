import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lights_out/constants.dart';

import 'screens/game_screen.dart';

/// Entry point for the Lights Out application.
void main() {
  runApp(const LightsOut());
}

class LightsOut extends StatelessWidget {
  const LightsOut({super.key});

  @override
  Widget build(BuildContext context) {
    // Lock the orientation for now since we have not created the landscape
    // layout yet.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: appTitle,
      initialRoute: GameScreen.id,
      routes: {
        GameScreen.id: (context) => const GameScreen(),
      },
    );
  }
}
