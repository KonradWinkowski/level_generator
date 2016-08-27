//
//  BasicObject.m
//  level_generator
//
//  Created by Konrad Winkowski on 8/26/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import "BasicObject.h"

@implementation BasicObject

- (CGFloat) randomNumberBetween0and1 {
    return random() / (float)0x7fffffff;
}

@end
