import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/collisions.dart';
import 'package:flutter_rpg_game/components/character.dart';
import 'package:flutter_rpg_game/main.dart';
import 'package:flame/input.dart';  // Make sure to import the Flame input package

class PlayerComponent extends Character with HasGameReference<MyCircle> {

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
    deadAnimation = spriteSheet.createAnimationByLimit(
        xInit: 0, yInit: 0, step: 8, sizeX: 5, stepTime: 0.08);
    idleAnimation = spriteSheet.createAnimationByLimit(
        xInit: 1, yInit: 2, step: 10, sizeX: 5, stepTime: 0.08);
    jumpAnimation = spriteSheet.createAnimationByLimit(
        xInit: 3, yInit: 0, step: 12, sizeX: 5, stepTime: 0.08);
    runAnimation = spriteSheet.createAnimationByLimit(
        xInit: 5, yInit: 0, step: 8, sizeX: 5, stepTime: 0.08);
    walkAnimation = spriteSheet.createAnimationByLimit(
        xInit: 6, yInit: 2, step: 10, sizeX: 5, stepTime: 0.08);
    walkSlowAnimation = spriteSheet.createAnimationByLimit(
        xInit: 6, yInit: 2, step: 10, sizeX: 5, stepTime: 0.08,);
    
    // Set initial animation
    animation = idleAnimation;

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
    position: Vector2(0,0)));
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      // Handle key down events
      //run right
      if((keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) && 
        keysPressed.contains(LogicalKeyboardKey.shiftLeft)) {
          animation = runAnimation;
          playerSpeed = 1500;
          if(!right)flipHorizontally();
          right = true;
          if(!collisionXRight)posX++;
      }
      //run left
      else if((keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
            keysPressed.contains(LogicalKeyboardKey.keyA)) &&
            keysPressed.contains(LogicalKeyboardKey.shiftLeft)) {
              animation = runAnimation;
              playerSpeed = 1500;
              if(right)flipHorizontally();
              right = false;
              if(!collisionXLeft)posX--;
      }
    
        
      
      //walk right
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keysPressed.contains(LogicalKeyboardKey.keyD))  {
        animation = walkAnimation;
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
        animation = walkAnimation;
        playerSpeed = 500;
          if (right) flipHorizontally();
        right = false;
        posX-=5;
        if(!collisionXLeft) posX--;
        return true;  // Indicate the event was handled
      } else {
        animation = walkSlowAnimation;
      }

    //Up/Jump
    if(keysPressed.contains(LogicalKeyboardKey.space)) {
        animation = jumpAnimation;
        playerSpeed = 500;
          if (right) flipHorizontally();
        right = false;
        if(!collisionYRight)posY--;
        velocity.y = -jumpForce;
        position.y -= 15;
      }
    //WalkSlow
    
    //down
    if(keysPressed.contains(LogicalKeyboardKey.arrowDown)  ||
      keysPressed.contains(LogicalKeyboardKey.keyS)) {
        animation = walkAnimation;
        playerSpeed = 500;
          if (right) flipHorizontally();
          right = false;
        if(!collisionYRight)posY++;
      }
      return true;

    } else if (event is KeyUpEvent) {
      // Handle key up events (stop movement or return to idle state)
      animation = idleAnimation;
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
    //implementing gravity
    if(position.y < 800 - size.x) {
      velocity.y += gravity;
      position.y += velocity.y * dt;
      onGround = false;
    } else {
      onGround = true;
    }

    posX = 0;
    posY = 0;
    super.update(dt);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(other is ScreenHitbox) {
      if(intersectionPoints.first[0] <= 0.0) {
        //left
        collisionXLeft = true;
      } else if (intersectionPoints.first[0] >= game.size.x) {
      collisionXRight = true;
      }
      super.onCollisionStart(intersectionPoints, other);  //left
    }


    // final firstPoint = intersectionPoints.first;

    // double collisionX = firstPoint.x;
    // double collisionY = firstPoint.y;

    // if (collisionX <= 0.0) {
    //   //Left side collision
    // } else if (collisionX >= game.size.x) {
    //   //Right side collision
    // }
    
    // if (collisionY <= 0.0) {
    //   //Up collision
    // } else if (collisionY >= game.size.y) {
    //   //down collision
    // }
    
    
    super.onCollision(intersectionPoints, other);
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
