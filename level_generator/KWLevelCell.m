//
//  KWLevelCell.m
//  level_generator
//
//  Created by Konrad Winkowski on 8/24/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import "KWLevelCell.h"

@implementation KWLevelCell

-(instancetype)initWithCoordinate:(CGPoint)coordinate {
    if (self = [super init]) {
        _coordinate = coordinate;
        _type = LevelCellType_Invalid;
    }
    
    return self;
}

@end
