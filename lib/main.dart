import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/spritesheet.dart';

import './game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await Flame.util.setLandscape();
    await Flame.util.fullScreen();
  }

  final size = await Flame.util.initialDimensions();

  await Flame.images.load('walls.png');
  final textures = SpriteSheet(
      imageName: 'walls.png',
      textureWidth: 64,
      textureHeight: 64,
      columns: 2,
      rows: 4,
  );

  runApp(FlameShooterGame(size, textures).widget);
}
