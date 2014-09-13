//
//  Obstacle.m
//  SantaRun
//
//  Created by Rootul Patel on 9/13/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Obstacle.h"
@implementation Obstacle {
    CCNode *_house;
}

- (void)didLoadFromCCB {
    _house.physicsBody.collisionType = @"house";
    _house.physicsBody.sensor = TRUE;
}

@end
