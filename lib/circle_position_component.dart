import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';

class CirclePositionComponent extends PositionComponent with CollisionCallbacks, HasGameReference {
  CirclePositionComponent({this.countActive = false});

  bool isHalfSize = false; // Track if the circle is currently in its half-size state
  bool countActive;
  int count = 0;
  
  static const double fullSize = 100.0;
  static const double halfSize = fullSize/2;
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
    debugMode = false;
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
      _toggleSize();
      circleDirectionX = 1;
      position.x = tolerance;  // Move away from the edge
    } else if (collisionPoint.x >= game.size.x - circleWidth - tolerance) {
      // Invert X direction on right edge collision
      _toggleSize();
      circleDirectionX = -1;
      position.x = game.size.x - circleWidth - tolerance;  // Move away from the edge
    }

    // Change color on collision with screen boundaries
    hitbox.paint.color = ColorExtension.random();
  }

  if(other is CirclePositionComponent) {
    //Reverse direction when colliding with another circle
    circleDirectionX *=-1;
    circleDirectionY *=-1;

    CirclePositionComponent otherCircle = other;

    // Reverse the direction of the other circle as well
    otherCircle.circleDirectionX *= -1;
    otherCircle.circleDirectionY *= -1;
  }


  super.onCollision(intersectionPoints, other);
}

  //Function to toggle between full size and half size
  void _toggleSize() {
    if(isHalfSize) {
      //if currently half-size, return to full size
      size = Vector2(fullSize, fullSize);

    } else {
      //If currently full-size, resize to half size
      size = Vector2(halfSize, halfSize);
    }
    isHalfSize = !isHalfSize; //Toggle the flag
  }


}