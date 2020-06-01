import 'package:flame/palette.dart';
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
  }) {
		final strip = strips[stripIdx];

		dist = sqrt(dist);

		// use perpendicular distance to adjust for fish eye
		// distorted_dist = correct_dist / cos(relative_angle_of_ray)
		dist = dist * cos(gameRef.player.rotation - rayAngle);

		// now calc the position, height and width of the wall strip

		// "real" wall height in the game world is 1 unit, the distance from the player to the screen is viewDist,
		// thus the height on the screen is equal to wall_height_real * viewDist / dist

		final height = (gameRef.viewDist / dist);

		// width is the same, but we have to stretch the texture to a factor of stripWidth to make it fill the strip correctly
		final width = height * FlameShooterGame.STRIP_WIDTH;

		// top placement is easy since everything is centered on the x-axis, so we simply move
		// it half way down the screen and then half the wall height back up.
		final top = ((FlameShooterGame.SCREEN_HEIGHT - height) / 2);

    strip.updateContainer(
        top: top,
        height: height,
    );
		//strip.style.height = height+"px";
		//strip.style.top = top+"px";

		//strip.img.style.height = Math.floor(height * numTextures) + "px";
		//strip.img.style.width = Math.floor(width*2) +"px";
		//strip.img.style.top = -Math.floor(height * (wallType-1)) + "px";

		//var texX = Math.round(textureX*width);

		//if (texX > width - stripWidth)
		//	texX = width - stripWidth;

		//strip.img.style.left = -texX + "px";
  }
}

class Strip {
  int i;
  Rect container;

  Strip(this.i);

  void reset() {
    container = Rect.fromLTWH(
        (i * FlameShooterGame.STRIP_WIDTH).toDouble(),
        0,
        FlameShooterGame.STRIP_WIDTH.toDouble(),
        0,
    );
  }

  void updateContainer({
    @required double top,
    @required double height,
  }) {
    container = Rect.fromLTWH(
        (i * FlameShooterGame.STRIP_WIDTH).toDouble(),
        top,
        FlameShooterGame.STRIP_WIDTH.toDouble(),
        height,
    );
  }

  void updateDimensions({
    @required double top,
    @required double width,
    @required double height,
  }) {
    //rect = Rect.fromLTWH(
    //    (i * FlameShooterGame.STRIP_WIDTH).toDouble(),
    //    top,
    //    width,
    //    height,
    //);
  }

  void drawStrip(Canvas canvas) {
    // TODO container shouldn't be used to render, probably just to clip
    canvas.drawRect(container, BasicPalette.white.paint);
  }
}
