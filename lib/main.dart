import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/timer.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rpg_game/components/player_component.dart';
import 'components/circle_position_component.dart';  // Import your CirclePositionComponent class here

void main() async {
  runApp(GameWidget(game: MyCircle()));
}

class MyCircle extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  late Timer _circleSpawnTimer;
  late PlayerComponent player;
  int _circleCount = 0;  //Counter to track the number of circles
  final int _maxCircles = 100; //Maximum number of circles allowed


  @override
  Future<void> onLoad() async {
    player = PlayerComponent();
    add(player);
    // Add initial circle
    add(CirclePositionComponent());
    _circleCount++;

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
    if(_circleCount < _maxCircles) {
    add(CirclePositionComponent());
    _circleCount++; //Increment the circle count
    } else {
      //If the limit is reached, stop the timer
      _circleSpawnTimer.stop();
    }
  }

  @override
  void update(double dt) {
    // Update the timer on every frame
    _circleSpawnTimer.update(dt);
    super.update(dt);
  }
}