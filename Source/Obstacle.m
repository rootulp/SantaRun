
//
//  Obstacle.m
//  SantaRun
//
//  Created by Rootul Patel on 9/13/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Obstacle.h"
@implementation Obstacle {
    CCNode *_obstacle;
}

- (void)didLoadFromCCB {
    _obstacle.physicsBody.collisionType = @"obstacle";
    _obstacle.physicsBody.sensor = TRUE;
}

@end
