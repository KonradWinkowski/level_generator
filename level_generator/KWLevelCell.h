//
//  KWLevelCell.h
//  level_generator
//
//  Created by Konrad Winkowski on 8/24/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM (NSInteger, LevelCellType)
{
    LevelCellType_Invalid = -1,
    LevelCellType_Wall,
    LevelCellType_Floor,
    LevelCellType_Max
};

@interface KWLevelCell : NSObject

@property (nonatomic, assign) CGPoint coordinate;
@property (nonatomic, assign) LevelCellType type;

-(instancetype)initWithCoordinate:(CGPoint)coordinate;

@end
