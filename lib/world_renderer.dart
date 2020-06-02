import 'package:flame/sprite.dart';
import 'package:meta/meta.dart';
import 'dart:ui';
import 'dart:math';

import './game.dart';

class WorldRenderer {
  List<Strip> strips = [];
  FlameShooterGame gameRef;

  WorldRenderer(this.gameRef);

  void init() {
    for (int i = 0; i < FlameShooterGame.SCREEN_WIDTH; i += FlameShooterGame.STRIP_WIDTH) {
      strips.add(
          Strip(i)..reset()
      );
    }
  }

  void reset() {
    strips.forEach((s) => s.reset());
  }

  void render(Canvas canvas) {
    strips.forEach((s) => s.drawStrip(canvas));
  }

  void updateStrip({
    @required int stripIdx,
    @required double dist,
    @required double rayAngle,
    @required int wallType,
    @required double textureX,
  }) {
		final strip = strips[stripIdx];

		dist = sqrt(dist);

		dist = dist * cos(gameRef.player.rotation - rayAngle);
		final height = (gameRef.viewDist / dist);

		final width = height * FlameShooterGame.STRIP_WIDTH;

		final top = ((FlameShooterGame.SCREEN_HEIGHT - height) / 2);

		double texX = (textureX * width);

		if (texX > width - FlameShooterGame.STRIP_WIDTH)
			texX = width - FlameShooterGame.STRIP_WIDTH;

    strip.updateContainer(
        top: top,
        height: height,
        texture: gameRef.textures.getSprite(wallType - 1, 0),
        textureX: texX,
    );
  }
}

class Strip {
  int i;
  Rect container;

  Sprite texture;
  Rect textureRect;

  Strip(this.i);

  void reset() {
    container = Rect.fromLTWH(
        (i * FlameShooterGame.STRIP_WIDTH).toDouble(),
        0,
        FlameShooterGame.STRIP_WIDTH.toDouble() * 2,
        0,
    );
  }

  void updateContainer({
    @required double top,
    @required double height,

    @required Sprite texture,
    @required double textureX,
  }) {
    container = Rect.fromLTWH(
        (i * FlameShooterGame.STRIP_WIDTH).toDouble(),
        top,
        FlameShooterGame.STRIP_WIDTH.toDouble() * 2,
        height,
    );

    this.texture = texture;
    textureRect = Rect.fromLTWH(
        (i * FlameShooterGame.STRIP_WIDTH).toDouble() - textureX,
        top,
        height * 2,
        height,
    );
  }

  void drawStrip(Canvas canvas) {
    canvas.save();
    canvas.clipRect(container);
    texture.renderRect(canvas, textureRect);
    canvas.restore();
  }
}
