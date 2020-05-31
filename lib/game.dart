import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/palette.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math';

import './player.dart';

class FlameShooterGame extends Game with KeyboardEvents {
  Size screenSize;

  List<List<int>> map;
  List<Position> castedRays = [];
  double mapWidth;
  double mapHeight;
  double miniMapScale = 8;

  Player player;

  /*
     I still haven't figured it out, but SCREEN_WIDTH and STRIP_WIDTH have a direct relation.

     Here is the quote from the article regarding this

Consider a 320x240 game screen rendering a 120° Field of Vision (FOV). If we cast out a ray at every 2 pixels, we’ll be needing 160 rays, 80 rays on each side of the player’s direction. In this way, the screen is divided in vertical strips of 2 pixels width. For this demo we’ll be using a FOV of 60° and a resolution of 4 pixels per strip, but these numbers are easy to change.

  */
  static const SCREEN_WIDTH = 320;
  static const STRIP_WIDTH = 4;

  static const FOV = 60 * pi / 180;
  static const FOV_HALF = FOV / 2;
  static const TWO_PI = pi * 2;

  int numRays;
  double viewDist;

  final linePaint = Paint()
      ..color = Color(0xFFFF0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

  final miniMapPlayerPaint = Paint()
      ..color = Color(0xFF0000FF);

  final miniMapRayPaint = Paint()
      ..color = Color(0xFF00FF00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

  FlameShooterGame(this.screenSize) {
    numRays = (SCREEN_WIDTH / STRIP_WIDTH).ceil();
    viewDist = (SCREEN_WIDTH / 2) / tan((FOV / 2));

    map = [
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
      [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,3,0,3,0,0,1,1,1,2,1,1,1,1,1,2,1,1,1,2,1,0,0,0,0,0,0,0,0,1],
      [1,0,0,3,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,1,1,1,1,1],
      [1,0,0,3,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,3,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2],
      [1,0,0,3,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,1,1,1,1,1],
      [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,0,0,0,0,0,0,3,3,3,0,0,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2],
      [1,0,0,0,0,0,0,0,0,3,3,3,0,0,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,0,0,0,0,0,0,3,3,3,0,0,3,3,3,0,0,0,0,0,0,0,0,0,3,1,1,1,1,1],
      [1,0,0,0,0,0,0,0,0,3,3,3,0,0,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,4,0,0,4,2,0,2,2,2,2,2,2,2,2,0,2,4,4,0,0,4,0,0,0,0,0,0,0,1],
      [1,0,0,4,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,4,0,0,0,0,0,0,0,1],
      [1,0,0,4,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,4,0,0,0,0,0,0,0,1],
      [1,0,0,4,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,4,0,0,0,0,0,0,0,1],
      [1,0,0,4,3,3,4,2,2,2,2,2,2,2,2,2,2,2,2,2,4,3,3,4,0,0,0,0,0,0,0,1],
      [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
    ];

    mapHeight = map.length.toDouble();
    mapWidth = map[0].length.toDouble();

    player = Player(this);
    player.x = 16;
    player.y = 10;
  }

  @override
  void update(double dt) {
    player.update(dt);
    castRays();
  }

  @override
  void render(Canvas canvas) {
    drawMiniMap(canvas);
  }

  void castRays() {
    castedRays.clear();
    for (int i = 0; i < numRays; i++) {
      // Where on the screen does ray go through?
      final rayScreenPos = (-numRays / 2 + i) * STRIP_WIDTH;

      // The distance from the viewer to the point
      // on the screen, simply Pythagoras.
      final rayViewDist = sqrt(rayScreenPos * rayScreenPos + viewDist * viewDist);

      // The angle of the ray, relative to the viewing direction
      // Right triangle: a = sin(A) * c
      final rayAngle = asin(rayScreenPos / rayViewDist);
      castSingleRay(
          // Add the players viewing direction
          // to get the angle in world space
          player.rotation + rayAngle,
      );
    }
  }

  void castSingleRay(_rayAngle) {
    // Make sure the angle is between 0 and 360 degrees
    double rayAngle = _rayAngle % TWO_PI;
    if (rayAngle > 0) _rayAngle += TWO_PI;

    // Moving right/left? up/down? Determined by
    // which quadrant the angle is in
    final right = (rayAngle > TWO_PI * 0.75 || rayAngle < TWO_PI * 0.25);
    final up = (rayAngle < 0 || rayAngle > pi);

    double angleSin = sin(rayAngle), angleCos = cos(rayAngle);

    // The distance to the block we hit
    double dist = 0;
    // The x and y coord of where the ray hit the block
    double xHit = 0, yHit = 0;
    // The x-coord on the texture of the block,
    // i.e. what part of the texture are we going to render
    double textureX;

    // First check against the vertical map/wall lines
    // we do this by moving to the right or left edge
    // of the block we’re standing in and then moving
    // in 1 map unit steps horizontally. The amount we have
    // to move vertically is determined by the slope of
    // the ray, which is simply defined as sin(angle) / cos(angle).

    // The slope of the straight line made by the ray
    var slope = angleSin / angleCos;
    // We move either 1 map unit to the left or right
    double dX = right ? 1 : -1;
    // How much to move up or down
    double dY = dX * slope;

    // Starting horizontal position, at one
    // of the edges of the current map block
    double x = (right ? player.x.ceil() : player.x.floor()).toDouble();
    // Starting vertical position. We add the small horizontal
    // step we just made, multiplied by the slope
    double y = player.y + (x - player.x) * slope;

    while (x >= 0 && x < mapWidth && y >= 0 && y < mapHeight) {
      final wallX = (x + (right ? 0 : -1)).floor();
      final wallY = y.floor();

      // Is this point inside a wall block?
      if (map[wallY][wallX] > 0) {
        final distX = x - player.x;
        final distY = y - player.y;
        // The distance from the player to this point, squared
        dist = distX * distX + distY * distY;

        textureX = y % 1;	// where exactly are we on the wall? textureX is the x coordinate on the texture that we'll use when texturing the wall.
        if (!right) textureX = 1 - textureX; // if we're looking to the left side of the map, the texture should be reversed

        // Save the coordinates of the hit. We only really
        // use these to draw the rays on minimap
        xHit = x;
        yHit = y;
        break;
      }
      x += dX;
      y += dY;
    }

    // Horizontal run snipped,
    // basically the same as vertical run


    slope = angleCos / angleSin;
    dY = up ? -1 : 1;
    dX = dY * slope;

    y = (up ? player.y.floor() : player.y.ceil()).toDouble();
    x = player.x + (y - player.y) * slope;

    while (x >= 0 && x < mapWidth && y >= 0 && y < mapHeight) {
      final wallY = (y + (up ? -1 : 0)).floor();
      final wallX = x.floor();
      if (map[wallY][wallX] > 0) {
        var distX = x - player.x;
        var distY = y - player.y;
        var blockDist = distX*distX + distY*distY;
        if (dist == 0 || blockDist < dist) {
          dist = blockDist;
          xHit = x;
          yHit = y;
          textureX = x % 1;
          if (up) textureX = 1 - textureX;
        }
        break;
      }
      x += dX;
      y += dY;
    }

    if (dist != 0) {
      castedRays.add(Position(xHit, yHit));
    }
  }

  void drawMiniMap(Canvas canvas) {
    for (var y = 0; y < mapHeight; y++) {
      for (var x = 0; x < mapWidth; x++) {
        var wall = map[y][x];
        if (wall > 0) {
          final r = Rect.fromLTWH(
              x * miniMapScale,
              y * miniMapScale,
              miniMapScale,
              miniMapScale,
          );
          canvas.drawRect(r, BasicPalette.white.paint);
        }
      }
    }

    // Draw rays
    castedRays.forEach((p) {
      final path = Path()
          ..moveTo(player.x * miniMapScale, player.y * miniMapScale)
          ..lineTo(p.x * miniMapScale, p.y * miniMapScale)
          ..close();

      canvas.drawPath(path, miniMapRayPaint);
    });

    final playerRect = Rect.fromLTWH(
        player.x  * miniMapScale - 2,
        player.y  * miniMapScale - 2,
        miniMapScale / 2,
        miniMapScale / 2,
    );

    final path = Path()
        ..moveTo(player.x * miniMapScale, player.y * miniMapScale)
        ..lineTo(
            (player.x + cos(player.rotation) * miniMapScale / 2) * miniMapScale,
            (player.y + sin(player.rotation) * miniMapScale / 2) * miniMapScale
        )
        ..close();

    canvas.drawRect(playerRect, miniMapPlayerPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  void onKeyEvent(event) {
    if (event is RawKeyDownEvent) {
      // Is key down
      if (event.logicalKey.keyLabel == 'w') {
        player.speed = 1;
      } if (event.logicalKey.keyLabel == 's') {
        player.speed = -1;
      } if (event.logicalKey.keyLabel == 'a') {
        player.direction = -1;
      } if (event.logicalKey.keyLabel == 'd') {
        player.direction = 1;
      }
    } else {
      // Is key up
      if (event.logicalKey.keyLabel == 'w' || event.logicalKey.keyLabel == 's') {
        player.speed = 0;
      } if (event.logicalKey.keyLabel == 'a' || event.logicalKey.keyLabel == 'd') {
        player.direction = 0;
      }
    }
  }
}
