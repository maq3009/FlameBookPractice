import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/timer.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'circle_position_component.dart';  // Import your CirclePositionComponent class here

void main() async {
  runApp(GameWidget(game: MyCircle()));
}

class MyCircle extends FlameGame with HasCollisionDetection {
  late Timer _circleSpawnTimer;

  @override
  Future<void> onLoad() async {
    // Add initial circle
    add(CirclePositionComponent());

    // Add the screen hitbox for boundary collisions
    add(ScreenHitbox());

    // Initialize the timer to spawn a new circle every 3 seconds
    _circleSpawnTimer = Timer(3, onTick: _spawnCircle, repeat: true);
    
    // Start the timer
    _circleSpawnTimer.start();

    return super.onLoad();
  }

  // Function to add a new circle to the game
  void _spawnCircle() {
    add(CirclePositionComponent());
  }

  @override
  void update(double dt) {
    // Update the timer on every frame
    _circleSpawnTimer.update(dt);
    super.update(dt);
  }
}