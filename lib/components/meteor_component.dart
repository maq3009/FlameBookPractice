import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/palette.dart';


class MeteorComponent extends PositionComponent with CollisionCallbacks, HasGameReference {
  MeteorComponent({this.countActive = false});

  static const int circleSpeed = 500;
  static const double circleWidth = 100.0;
  static const double circleHeight = 100.0;

  int circleDirectionX = 1;
  int circleDirectionY = 1;

  Random random = Random();

  int count = 0;
  bool countActive;

  late double screenWidth;
  late double screenHeight;

  final ShapeHitbox shapeHitbox = CircleHitbox();

  @override
  void update(dt) {
    position.x += circleDirectionX * circleSpeed * dt;
    position.y += circleDirectionY * circleSpeed * dt;
    super.update(dt);
  }

  @override
  void onLoad() {
    screenWidth = game.size.x;
    screenHeight = game.size.y;

    circleDirectionX = random.nextInt(2) == 1? 1: -1;
    circleDirectionY = random.nextInt(2) == 1? 1: -1;

    position = Vector2(random.nextDouble() * 500, random.nextDouble() * 500);
    size = Vector2(circleWidth, circleHeight);

    shapeHitbox.paint.color = BasicPalette.green.color;
    shapeHitbox.renderShape = true;

    add(shapeHitbox);
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if(other is ScreenHitbox) {
      if(points.first[1] <= 0.0) {
        // top
        circleDirectionX = random.nextInt(2) == 1? 1: -1;
        circleDirectionY *=-1;
      } else if(points.first[1] >= game.size) {
        //bottom
        circleDirectionX = random.nextInt(2) == 1? 1:-1;
        circleDirectionY *=-1;
      } else if(points.first[0] <= 0.0) {
        //left
        circleDirectionX *=-1;
        circleDirectionY = random.nextInt(2) == 1? 1: -1;
      } else if (points.first[0] >= game.size.x) {
        //right
        circleDirectionX *=-1;
        circleDirectionY = random.nextInt(2) == 1? 1: -1;
      }
      //hitbox.paint.color = BasicPalette.red.color;
      shapeHitbox.paint.color = ColorExtension.random();
    }

    if(other is MeteorComponent) {
      circleDirectionX *=-1;
      circleDirectionY *=-1;
    }

    if(countActive) {
      count++;
      print(count);
    }

    super.onCollision(points, other);
  }
}