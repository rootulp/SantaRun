//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Obstacle.h"
#import "Present.h"

BOOL _gameOver;
CGFloat _scrollSpeed;
static const CGFloat firstObstaclePosition = 150.f;
static const CGFloat firstPresentPosition = 150.f;
static const CGFloat distanceBetweenObstacles = 150.f;
static const CGFloat distanceBetweenObstacleAndFloor = 87.f;
static const CGFloat distanceBetweenObstacleAndCeiling = 225.f;
static const CGFloat distanceBetweenPresents = 150.f;
static const CGFloat distanceBetweenPresentAndFloor = 87.f;
static const CGFloat distanceBetweenPresentAndCeiling = 225.f;

@implementation MainScene {
    CCSprite *_hero;
    CCPhysicsNode *_physicsNode;
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_ground_small1;
    CCNode *_ground_small2;
    CCButton *_restartButton;
    NSArray *_grounds;
    NSArray *_grounds_small;
    NSMutableArray *_obstacles;
    NSMutableArray *_presents;
    NSInteger _points;
    CCLabelTTF *_scoreLabel;
}
- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    _grounds = @[_ground1, _ground2];
    _grounds_small = @[_ground_small1, _ground_small2];
    for (CCNode *ground in _grounds) {
        // set collision txpe
        ground.physicsBody.collisionType = @"level";
    }
    for (CCNode *ground in _grounds_small) {
        // set collision txpe
        ground.physicsBody.collisionType = @"level";
    }
    // set this class as delegate
    _physicsNode.collisionDelegate = self;
    // set collision txpe
    _hero.physicsBody.collisionType = @"hero";
    _obstacles = [NSMutableArray array];
    _presents = [NSMutableArray array];
    [self spawnBoth];
    [self spawnBoth];
    [self spawnBoth];
    _scrollSpeed = 80.f;
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if(!_gameOver) {
        if (_hero.position.y > 200) {
            _hero.position = ccp(_hero.position.x, 118);
        } else {
            _hero.position = ccp(_hero.position.x, 255);
        }
    }
    
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero house:(CCNode *)house
{
    [self gameOver];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero present:(CCNode *)present {
    [present removeFromParent];
    _points++;
    _scoreLabel.string = [NSString stringWithFormat:@"Score: %d", _points];
    return TRUE;
}

- (void)spawnBoth {
    #define ARC4RANDOM_MAX      0x100000000
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX);
    if (random > .5) {
        
        [self spawnNewObstacle:(BOOL) true ];
        [self spawnNewPresent:(BOOL) false];
    } else {
        [self spawnNewPresent:(BOOL) true];
        [self spawnNewObstacle:(BOOL) false];
    }
}

- (void)spawnNewObstacle:(BOOL)top {
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    if (!previousObstacle) {
        // this is the first obstacle
        previousObstacleXPosition = firstObstaclePosition;
    }
    CCNode *obstacle = [CCBReader load:@"Obstacle"];
    if (top) {
        obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, distanceBetweenObstacleAndCeiling);
    } else {
        obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, distanceBetweenObstacleAndFloor);
    }
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
}

- (void)spawnNewPresent:(BOOL)top {
    CCNode *previousPresent = [_presents lastObject];
    CGFloat previousPresentXPosition = previousPresent.position.x;
    if (!previousPresent) {
        // this is the first present
        previousPresentXPosition = firstPresentPosition;
    }
    CCNode *present = [CCBReader load:@"Present"];
    if (top) {
        present.position = ccp(previousPresentXPosition + distanceBetweenPresents, distanceBetweenPresentAndCeiling);
    } else {
        present.position = ccp(previousPresentXPosition + distanceBetweenPresents, distanceBetweenPresentAndFloor);
    }
    
    [_physicsNode addChild:present];
    [_presents addObject:present];
}

- (void)update:(CCTime)delta {
    _hero.position = ccp(_hero.position.x + delta * _scrollSpeed, _hero.position.y);
    _physicsNode.position = ccp(_physicsNode.position.x - (_scrollSpeed *delta), _physicsNode.position.y);
    // loop the ground
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }
    for (CCNode *ground in _grounds_small) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }
    // clamp velocity
    float yVelocity = clampf(_hero.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
    _hero.physicsBody.velocity = ccp(0, yVelocity);
    
    NSMutableArray *offScreenObstacles = nil;
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
        // for each removed obstacle, add a new one
        [self spawnBoth];
    }
    
}

- (void)gameOver {
    if (!_gameOver) {
        _scrollSpeed = 0.f;
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        [_hero stopAllActions];
        [_hero.animationManager setPaused:YES];
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        [self runAction:bounce];
    }
}

- (void)restart {
    _gameOver = FALSE;
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}
@end
