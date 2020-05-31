import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math';

import './player.dart';

class FlameShooterGame extends Game with KeyboardEvents {
  Size screenSize;

  List<List<int>> map;
  double mapWidth;
  double mapHeight;
  double miniMapScale = 8;

  final Player player = Player();

  final linePaint = Paint()
        ..color = Color(0xFFFF0000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

  final miniMapPlayerPaint = Paint()
      ..color = Color(0xFF0000FF);

  FlameShooterGame(this.screenSize) {
    map = [
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
      [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,2,0,0,0,0,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,2,0,0,0,0,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,0,0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,0,0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
      [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
    ];

      mapHeight = map.length.toDouble();
      mapWidth = map[0].length.toDouble();

      player.x = 1;
      player.y = 1;
  }

  @override
  void update(double dt) {
    player.update(dt);
  }

  @override
  void render(Canvas canvas) {
    drawMiniMap(canvas);
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
      if (event.logicalKey.keyLabel == 'w' || event.logicalKey.keyLabel == 's') {
        player.speed = 0;
      } if (event.logicalKey.keyLabel == 'a' || event.logicalKey.keyLabel == 'd') {
        player.direction = 0;
      }
      // Is key up
    }
  }
}
