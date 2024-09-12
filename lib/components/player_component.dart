import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/collisions.dart';
import 'package:flutter_rpg_game/main.dart';
import 'package:flame/input.dart';  // Make sure to import the Flame input package

class PlayerComponent extends SpriteAnimationComponent
    with KeyboardHandler, CollisionCallbacks, HasGameReference<MyCircle> {
  PlayerComponent({
    super.position,
    super.size,
    super.anchor,
  });

  bool collisionXRight = false, collisionXLeft = false;
  bool collisionYRight = false, collisionYLeft = false;
  late double screenWidth, screenHeight, centerX, centerY;
  final double spriteSheetWidth = 1090, spriteSheetHeight = 984;
  int posX = 0, posY = 0;
  double playerSpeed = 500;

  int animationIndex = 0;

  bool right = true;

  late SpriteAnimation 
      dinoDeadAnimation,
      dinoIdleAnimation,
      dinoJumpAnimation,
      dinoRunAnimation,
      dinoWalkAnimation,
      dinoWalkSlowAnimation;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    debugMode = true;

    // Load sprite sheet
    final spriteImage = await Flame.images.load('dinoFull.png');
    final spriteSheet = SpriteSheet(
      image: spriteImage,
      srcSize: Vector2((spriteSheetWidth / 6) , spriteSheetHeight / 8),
    );

    // Initialize animations
    dinoDeadAnimation = spriteSheet.createAnimationByLimit(
        xInit: 0, yInit: 0, step: 8, sizeX: 6, stepTime: 0.08);
    dinoIdleAnimation = spriteSheet.createAnimationByLimit(
        xInit: 1, yInit: 2, step: 10, sizeX: 6, stepTime: 0.08);
    dinoJumpAnimation = spriteSheet.createAnimationByLimit(
        xInit: 3, yInit: 0, step: 12, sizeX: 6, stepTime: 0.08);
    dinoRunAnimation = spriteSheet.createAnimationByLimit(
        xInit: 5, yInit: 0, step: 8, sizeX: 6, stepTime: 0.08);
    dinoWalkAnimation = spriteSheet.createAnimationByLimit(
        xInit: 6, yInit: 2, step: 10, sizeX: 6, stepTime: 0.08);
    dinoWalkSlowAnimation = spriteSheet.createAnimationByLimit(
        xInit: 6, yInit: 2, step: 10, sizeX: 5, stepTime: .32,);
    
    // Set initial animation
    animation = dinoIdleAnimation;

    // Get screen size from the game
    screenWidth = game.size.x;
    screenHeight = game.size.y;

    size = Vector2(spriteSheetWidth / 6, spriteSheetHeight / 8);
    centerX = (screenWidth / 2) - (spriteSheetWidth / 6);
    centerY = (screenHeight / 2) - (spriteSheetHeight /8);
    position = Vector2(centerX, centerY);

    // Add collision hitbox
    add(RectangleHitbox(
    size: Vector2(spriteSheetWidth / 6, spriteSheetHeight / 8),
    position: Vector2(0, 0)));
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      // Handle key down events
      //run right
      if((keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) && 
        keysPressed.contains(LogicalKeyboardKey.shiftLeft)) {
          animation = dinoRunAnimation;
          playerSpeed = 1500;
          if(!right)flipHorizontally();
          right = true;
          if(!collisionXRight)posX++;
      }
      //run left
      else if((keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
            keysPressed.contains(LogicalKeyboardKey.keyA)) &&
            keysPressed.contains(LogicalKeyboardKey.shiftLeft)) {
              animation = dinoRunAnimation;
              playerSpeed = 1500;
              if(right)flipHorizontally();
              right = false;
              if(!collisionXLeft)posX--;
      }
    
        
      
      //walk right
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keysPressed.contains(LogicalKeyboardKey.keyD))  {
        animation = dinoWalkAnimation;
        playerSpeed = 500;
        if (!right) flipHorizontally();
        right = true;
        posX+=5;
        if(!collisionXRight) posX++;
        return true;  // Indicate the event was handled
      }
      //walk left
       else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
        animation = dinoWalkAnimation;
        playerSpeed = 500;
          if (right) flipHorizontally();
        right = false;
        posX-=5;
        if(!collisionXLeft) posX--;
        return true;  // Indicate the event was handled
      } else {
        animation = dinoWalkSlowAnimation;
      }

    //Up
    if(keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
      keysPressed.contains(LogicalKeyboardKey.keyW)) {
        animation = dinoWalkAnimation;
        playerSpeed = 500;
          if (right) flipHorizontally();
        right = false;
        if(!collisionYRight)posY--;
      }
    //WalkSlow
    
    //down
    if(keysPressed.contains(LogicalKeyboardKey.arrowDown)  ||
      keysPressed.contains(LogicalKeyboardKey.keyS)) {
        animation = dinoWalkAnimation;
        playerSpeed = 500;
          if (right) flipHorizontally();
          right = false;
        if(!collisionYRight)posY++;
      }
      return true;

    } else if (event is KeyUpEvent) {
      // Handle key up events (stop movement or return to idle state)
      animation = dinoIdleAnimation;
      return true;  // Indicate the event was handled
    }

    return false;  // Return false if the key event isn't handled
  }

  @override
  void update(double dt) {
    position.x += playerSpeed * dt * posX;
    position.y += playerSpeed * dt * posY;

    //prevent the dino from moving off the left side
    if(position.x - size.x / 2 < 0) {
      position.x = size.x / 2;

    }
    //prevent dino from moving off the right side
    if(position.x + size.x / 2 > screenWidth) {
      position.x = screenWidth - size.x / 2;
    }

    //prevent dino from moving off the top of screen
    if(position.y + size.y / 2 > screenHeight) {
      position.y = screenHeight - size.y / 2;
    }

    //prevent dino from moving off the bottom of the screen
    if(position.y - size.y / 2 < 0 ) {
      position.y = size.y / 2;

    }

    posX = 0;
    posY = 0;
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    }
  }



// Extension to create animation from sprite sheet
extension CreateAnimationByLimit on SpriteSheet {
  SpriteAnimation createAnimationByLimit({
    required int xInit, //Gives you beginning y index of spriteSheet
    required int yInit, //Gives you beginning x index of spriteSheet
    required int step,
    required int sizeX,
    required double stepTime,
    bool loop = true,
  }) {
    final List<Sprite> spriteList = [];
    int x = xInit;
    int y = yInit;
    for (var i = 0; i < step; i++) {
      if (y >= sizeX) {
        y = 0;
        x++;
      } else {
        y++;
      }
      spriteList.add(getSprite(x, y));
    }

    return SpriteAnimation.spriteList(spriteList, stepTime: stepTime, loop: loop);
  }
}
