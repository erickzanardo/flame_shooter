import 'dart:math';

import './game.dart';

class Player {
  static const TWO_PI = pi * 2;

  static const MOVE_SPEED = 6;
  static const ROTATE_SPEED = 60 * pi / 180;

  FlameShooterGame gameRef;

  Player(this.gameRef);

  double x = 0;
  double y = 0;
  int direction = 0;
  double rotation = 0;
  int speed = 0;

  void update(double dt) {
    // Player will move this far along
    // the current direction vector
    final moveStep = speed * MOVE_SPEED * dt;

    // Add rotation if player is rotating (player.dir != 0)
    rotation += direction * ROTATE_SPEED * dt;

    // make sure the angle is between 0 and 360 degrees
    while (rotation < 0) rotation += TWO_PI;
    while (rotation >= TWO_PI) rotation -= TWO_PI;

    // Calculate new player position with simple trigonometry
    final newX = x + cos(rotation) * moveStep;
    final newY = y + sin(rotation) * moveStep;

    // Set new position
    if (!isBlocking(newX, newY)) {
      x = newX;
      y = newY;
    }
  }

  bool isBlocking(double x, double y) {
    // check boundaries of the level
    if (y < 0 || y >= gameRef.mapHeight || x < 0 || x >= gameRef.mapWidth) {
      return true;
    }
    return (gameRef.map[y.floor()][x.floor()] != 0);
  }
}
