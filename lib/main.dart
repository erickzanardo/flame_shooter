import 'package:flutter/material.dart';
import 'package:flame/flame.dart';

import './game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final size = await Flame.util.initialDimensions();
  runApp(FlameShooterGame(size).widget);
}
