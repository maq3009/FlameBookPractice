import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class CirclePositionComponent extends PositionComponent with CollisionCallbacks, HasGameReference {
  CirclePositionComponent({this.countActive = false});

  bool countActive;
  int count = 0;
  
  
  static const int circleSpeed = 250;
  static const circleWidth = 100.0;
  static const circleHeight = 100.0;

  int circleDirectionX = 1;
  int circleDirectionY = 1;

  Random random = Random();

  late double screenWidth;
  late double screenHeight;
  late double centerX;
  late double centerY;

  final ShapeHitbox hitbox = CircleHitbox();



  @override
  void update(double dt) {
    position.x += circleDirectionX * circleSpeed * dt;
    position.y += circleDirectionY * circleSpeed * dt;
    super.update(dt);
  }



  @override
  void onLoad() async {
    super.onLoad();
    debugMode = true;
    screenWidth = game.size.x;
    screenHeight = game.size.y;
    // add(RectangleHitbox(
    //   size: Vector2(circleWidth,circleHeight),
    //   position:  Vector2(20,0),
    //   ),
    // );
    double circleDirectionX = random.nextDouble() * (screenWidth - circleWidth);
    double circleDirectionY = random.nextDouble() * (screenHeight - circleHeight);

    position = Vector2(circleDirectionX,circleDirectionY);
    size = Vector2(circleWidth, circleHeight);

    hitbox.paint.color = BasicPalette.green.color;
    hitbox.renderShape = true;
    add(hitbox);
  }


@override
void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  if (other is ScreenHitbox) {
    Vector2 collisionPoint = intersectionPoints.first;

    // Adjust tolerance to avoid repeated collision at boundaries
    const tolerance = 1.0;

    // Check for collisions with the top and bottom of the screen
    if (collisionPoint.y <= tolerance) {
      // Invert Y direction on top edge collision
      circleDirectionY = 1;
      position.y = tolerance;  // Ensure the position moves slightly away from the edge
    } else if (collisionPoint.y >= game.size.y - circleHeight - tolerance) {
      // Invert Y direction on bottom edge collision
      circleDirectionY = -1;
      position.y = game.size.y - circleHeight - tolerance;  // Move away from the edge
    }

    // Check for collisions with the left and right of the screen
    if (collisionPoint.x <= tolerance) {
      // Invert X direction on left edge collision
      circleDirectionX = 1;
      position.x = tolerance;  // Move away from the edge
    } else if (collisionPoint.x >= game.size.x - circleWidth - tolerance) {
      // Invert X direction on right edge collision
      circleDirectionX = -1;
      position.x = game.size.x - circleWidth - tolerance;  // Move away from the edge
    }

    // Change color on collision with screen boundaries
    hitbox.paint.color = ColorExtension.random();
  }

  if (other is CirclePositionComponent) {
    // Reverse direction when colliding with another circle
    other.x *= -1;
    other.y *= 1;
  }

  super.onCollision(intersectionPoints, other);
}


}