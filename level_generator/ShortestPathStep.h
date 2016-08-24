//
//  ShortestPathStep.h
//  level_generator
//
//  Created by Konrad Winkowski on 8/24/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShortestPathStep : NSObject

@property (assign, nonatomic) CGPoint position;
@property (assign, nonatomic) NSInteger gScore;
@property (assign, nonatomic) NSInteger hScore;
@property (strong, nonatomic) ShortestPathStep *parent;

- (instancetype)initWithPosition:(CGPoint)pos;
- (NSInteger)fScore;

@end
