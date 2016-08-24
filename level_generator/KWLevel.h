//
//  KWLevel.h
//  level_generator
//
//  Created by Konrad Winkowski on 8/24/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface KWLevel : SKNode

@property (nonatomic, strong) NSArray *grid;
@property (nonatomic, assign) CGSize levelSize;
@property (assign, nonatomic) CGFloat chanceToBecomeWall;
@property (assign, nonatomic) NSUInteger floorsToWallConversion;
@property (assign, nonatomic) NSUInteger wallsToFloorConversion;
@property (nonatomic, assign) NSUInteger numberOfTransitionSteps;
@property (nonatomic, strong) NSMutableArray *caverns;
@property (nonatomic, assign) BOOL connectedCave;

-(instancetype)initWithLevelSize:(CGSize)levelSize;

-(void)generateWithSeed:(unsigned int)seed;

@end
