import 'dart:math';

class Player {
  static const MOVE_SPEED = 6;
  static const ROTATE_SPEED = 60 * pi / 180;

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

    // Calculate new player position with simple trigonometry
    final newX = x + cos(rotation) * moveStep;
    final newY = y + sin(rotation) * moveStep;

    // Set new position
    x = newX;
    y = newY;
  }
}
