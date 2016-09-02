//
//  KWLevel.h
//  level_generator
//
//  Created by Konrad Winkowski on 8/24/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class KWLevelCell;

@interface KWLevel : SKNode

@property (nonatomic, strong) NSArray *grid;
@property (nonatomic, assign) CGSize levelSize;
@property (assign, nonatomic) CGFloat chanceToBecomeWall;
@property (assign, nonatomic) NSUInteger floorsToWallConversion;
@property (assign, nonatomic) NSUInteger wallsToFloorConversion;
@property (nonatomic, assign) NSUInteger numberOfTransitionSteps;
@property (nonatomic, assign) BOOL connectedCave;

-(instancetype)initWithLevelSize:(CGSize)levelSize;

-(void)generateWithSeed:(unsigned int)seed;

-(CGPoint)randomPositionInMainPlayArea;

- (BOOL)isEdgeAtGridCoordinate:(CGPoint)coordinate;

-(KWLevelCell*)levelCellFromGridCoordinate:(CGPoint)coordiante;

-(BOOL)isValidCoordinate:(CGPoint)coordinate;

-(CGPoint)positionForGirdCoordinate:(CGPoint)coordinate;

- (CGFloat) randomNumberBetween0and1;

-(void)generateTiles;

@end
