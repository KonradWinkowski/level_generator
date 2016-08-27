//
//  EnemyObject.h
//  level_generator
//
//  Created by Konrad Winkowski on 8/27/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import "BasicObject.h"

typedef NS_ENUM(NSUInteger, Enemy_State)
{
    Enemy_State_Idle = 0,
    Enemy_State_Walking,
    Enemy_State_Running
};

@interface EnemyObject : BasicObject

@property (nonatomic, assign) CGVector velocity;
@property (nonatomic, assign) CGPoint desiredPosition;
@property (nonatomic, assign) Enemy_State state;

+(EnemyObject*)basicEnemy;

-(void)update:(CFTimeInterval)currentTime;

@end
