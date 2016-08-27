//
//  WallObject.m
//  level_generator
//
//  Created by Konrad Winkowski on 8/26/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import "WallObject.h"

@implementation WallObject

+(WallObject*)basicWall{
    return [[WallObject alloc] initWithPhysics];
}

-(instancetype)initWithPhysics {
    if (self = [super initWithColor:[SKColor blackColor] size:CGSizeMake(kTileSize, kTileSize)]){
        self.name = @"wall";
    }
    return self;
}

-(void)setupWallPhysics {
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.dynamic = NO;
    self.physicsBody.categoryBitMask = category_wall;
    self.physicsBody.collisionBitMask = category_player | category_enemy;
}

@end
