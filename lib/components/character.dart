import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Character extends SpriteAnimationComponent
    with KeyboardHandler, CollisionCallbacks {
  
  int animationIndex = 0;
  double gravity = 1.8;
  Vector2 velocity = Vector2(0, 0);

  late double screenWidth, screenHeight, centerX, centerY;
  final double spriteSheetWidth = 680, spriteSheetHeight = 472;
  int posX = 0, posY = 0;
  double playerSpeed = 500;
  final double jumpForce = 130;

  bool onGround = true;
  bool right = true;
  bool collisionXRight = false;
  bool collisionXLeft = false;

  late SpriteAnimation deadAnimation;
  late SpriteAnimation idleAnimation;
  late SpriteAnimation jumpAnimation;
  late SpriteAnimation runAnimation;
  late SpriteAnimation walkAnimation;
  late SpriteAnimation walkSlowAnimation;


  @override
  void update(double dt) {
    super.update(dt);
    // Add logic to update the character's position, animations, etc.
  }

}
