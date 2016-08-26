//
//  WallObject.h
//  level_generator
//
//  Created by Konrad Winkowski on 8/26/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import "BasicObject.h"

@interface WallObject : BasicObject

+(WallObject*)basicWall;

/**
 *  Sets up a static physics object for the wall. Should only be added if the wall needs to have a physics body attached to
 *  it. Some walls (such as ones that are sorounded by other walls do not need a physics body attached to them. This will
 *  improve performance.
 *
 */
-(void)setupWallPhysics;

@end
