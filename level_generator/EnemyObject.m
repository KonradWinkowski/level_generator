//
//  EnemyObject.m
//  level_generator
//
//  Created by Konrad Winkowski on 8/27/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import "EnemyObject.h"

#define kBasicEnemyMovementSpeed 25

#define SHOW_RAYS NO

@interface EnemyObject()

@property (assign, nonatomic) NSTimeInterval lastUpdateTimeInterval;

@property (assign, nonatomic) float angle;

@property (assign, nonatomic) float probibilityToStop;

@end

@implementation EnemyObject

+(EnemyObject*)basicEnemy {
    return [[EnemyObject alloc] initBasicEnemy];
}

-(instancetype)initBasicEnemy{
    if (self = [super initWithColor:[SKColor redColor] size:CGSizeMake(25, 25)]) {
        self.velocity = CGVectorMake(1.0, 0.0);
        [self setupBasicPhysics];
        
        self.probibilityToStop = 0.05;
        self.state = Enemy_State_Walking;
        
        if (SHOW_RAYS) {
            [self setupRays];
        }
    }
    return self;
}

-(void)setupRays {
    float x = 0 + 200 * cos(DEGREES_TO_RADIANS(30.0 + self.angle));
    float y = 0 + 200 * sin(DEGREES_TO_RADIANS(30.0 + self.angle));
    UIBezierPath *ray_one_path = [[UIBezierPath alloc] init];
    [ray_one_path moveToPoint:(CGPointMake(0, 0))];
    [ray_one_path addLineToPoint:CGPointMake(x, y)];
    
    SKShapeNode *ray_one = [SKShapeNode shapeNodeWithPath:ray_one_path.CGPath];
    ray_one.name = @"ray1";
    ray_one.fillColor = [SKColor whiteColor];
    ray_one.lineWidth = 2.0;
    [self addChild:ray_one];
    
    x = 0 + 200 * cos(DEGREES_TO_RADIANS(0.0 + self.angle));
    y = 0 + 200 * sin(DEGREES_TO_RADIANS(0.0 + self.angle));
    UIBezierPath *ray_two_path = [[UIBezierPath alloc] init];
    [ray_two_path moveToPoint:(CGPointMake(0, 0))];
    [ray_two_path addLineToPoint:CGPointMake(x, y)];
    
    SKShapeNode *ray_two = [SKShapeNode shapeNodeWithPath:ray_two_path.CGPath];
    ray_two.name = @"ray2";
    ray_two.fillColor = [SKColor whiteColor];
    ray_two.lineWidth = 2.0;
    [self addChild:ray_two];
    
    x = 0 + 200 * cos(DEGREES_TO_RADIANS(-30.0 + self.angle));
    y = 0 + 200 * sin(DEGREES_TO_RADIANS(-30.0 + self.angle));
    UIBezierPath *ray_three_path = [[UIBezierPath alloc] init];
    [ray_three_path moveToPoint:(CGPointMake(0, 0))];
    [ray_three_path addLineToPoint:CGPointMake(x, y)];
    
    SKShapeNode *ray_three = [SKShapeNode shapeNodeWithPath:ray_three_path.CGPath];
    ray_three.name = @"ray3";
    ray_three.fillColor = [SKColor whiteColor];
    ray_three.lineWidth = 2.0;
    [self addChild:ray_three];
}

-(void)setupBasicPhysics {
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.allowsRotation = NO;
    self.physicsBody.categoryBitMask = category_enemy;
    self.physicsBody.collisionBitMask = category_wall | category_enemy | category_player;
    self.physicsBody.linearDamping = 20.0;
}

-(void)update:(CFTimeInterval)currentTime {
    return;
    
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    
    self.lastUpdateTimeInterval = currentTime;
    
    if (timeSinceLast > 1) {
        timeSinceLast = 1.0f / 60.0f;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    if (self.scene && self.state != Enemy_State_Idle) {
        
        if ([self checkPathInFront]) { // something is in front so check sides
            if ([self checkPathToLeft] && ![self checkPathToRight]) {
                self.angle -= 2.0;
            } else if ([self checkPathToRight] && ![self checkPathToLeft]) {
                self.angle += 2.0;
            } else {
                if ([self randomNumberBetween0and1] <= self.probibilityToStop){
                    self.state = Enemy_State_Idle;
                    __weak typeof(self) weakself = self;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arc4random_uniform(5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        weakself.state = Enemy_State_Walking;
                    });
                } else {
                    self.angle += arc4random_uniform(20);
                }
            }
        } else if ([self checkPathToLeft] && ![self checkPathToRight]) {
            self.angle -= 1.0;
        } else if ([self checkPathToRight] && ![self checkPathToLeft]) {
            self.angle += 1.0;
        }
        
        float radiants = DEGREES_TO_RADIANS(self.angle);
        float cosAngle = cosf(radiants);
        float sinAngle = sinf(radiants);
        
        self.velocity = CGVectorMake(cosAngle, sinAngle);
        
        //    if (self.velocity.dx != 0 && self.velocity.dy != 0) {
        // Calculate the desired position for the player
        self.desiredPosition = CGPointMake(self.position.x + self.velocity.dx * timeSinceLast * kBasicEnemyMovementSpeed, self.position.y + self.velocity.dy * timeSinceLast * kBasicEnemyMovementSpeed);
        //    }
        
        
        self.position = self.desiredPosition;
    }
    
}

-(void)damageEnemy {
    
}

-(void)meleeAttackEnemy {
    [self.physicsBody applyImpulse:CGVectorMake(20.0, 15.0)];
}

- (void)stealthAttackEnemy {
    
    // animation //
    [self removeEnemyFromWorld];
    
}

-(void)removeEnemyFromWorld {
    [self removeAllActions];
    //TODO // // tell delegate that we are removing ourselves //
    [self removeFromParent];
}

-(BOOL)checkPathToRight {
    float ray_one_end_x = self.position.x + 150 * cosf(DEGREES_TO_RADIANS(-30.0 + self.angle));
    float ray_one_end_y = self.position.y + 150 * sinf(DEGREES_TO_RADIANS(-30.0 + self.angle));
    
    SKPhysicsBody *body_one = [self.scene.physicsWorld bodyAlongRayStart:self.position end:CGPointMake(ray_one_end_x, ray_one_end_y)];
    
    if (SHOW_RAYS ) {
        if (body_one) {
            NSLog(@"%@", body_one);
            SKShapeNode *ray_one = (SKShapeNode*)[self childNodeWithName:[NSString stringWithFormat:@"ray3"]];
            if (ray_one) {
                UIBezierPath *ray_two_path = [[UIBezierPath alloc] init];
                [ray_two_path moveToPoint:(CGPointMake(0, 0))];
                float x = 0 + 150 * cos(DEGREES_TO_RADIANS(-30.0 + self.angle));
                float y = 0 + 150 * sin(DEGREES_TO_RADIANS(-30.0 + self.angle));
                
                [ray_two_path addLineToPoint:CGPointMake(x, y)];
                ray_one.path = ray_two_path.CGPath;
                
                ray_one.strokeColor = [SKColor greenColor];
            }
        } else {
            SKShapeNode *ray_one = (SKShapeNode*)[self childNodeWithName:@"ray3"];
            if (ray_one) {
                UIBezierPath *ray_two_path = [[UIBezierPath alloc] init];
                [ray_two_path moveToPoint:(CGPointMake(0, 0))];
                float x = 0 + 150 * cos(DEGREES_TO_RADIANS(-30.0 + self.angle));
                float y = 0 + 150 * sin(DEGREES_TO_RADIANS(-30.0 + self.angle));
                
                [ray_two_path addLineToPoint:CGPointMake(x, y)];
                ray_one.path = ray_two_path.CGPath;
                
                ray_one.strokeColor = [SKColor whiteColor];
            }
        }
    }
    
    return (body_one) ? YES : NO;
}

-(BOOL)checkPathToLeft {
    float ray_one_end_x = self.position.x + 150 * cosf(DEGREES_TO_RADIANS(30.0 + self.angle));
    float ray_one_end_y = self.position.y + 150 * sinf(DEGREES_TO_RADIANS(30.0 + self.angle));
    
    SKPhysicsBody *body_one = [self.scene.physicsWorld bodyAlongRayStart:self.position end:CGPointMake(ray_one_end_x, ray_one_end_y)];
    if (SHOW_RAYS)
    {
        if (body_one) {
            NSLog(@"%@", body_one);
            SKShapeNode *ray_one = (SKShapeNode*)[self childNodeWithName:[NSString stringWithFormat:@"ray1"]];
            if (ray_one) {
                UIBezierPath *ray_two_path = [[UIBezierPath alloc] init];
                [ray_two_path moveToPoint:(CGPointMake(0, 0))];
                float x = 0 + 150 * cos(DEGREES_TO_RADIANS(30.0 + self.angle));
                float y = 0 + 150 * sin(DEGREES_TO_RADIANS(30.0 + self.angle));
                
                [ray_two_path addLineToPoint:CGPointMake(x, y)];
                ray_one.path = ray_two_path.CGPath;
                
                ray_one.strokeColor = [SKColor greenColor];
            }
        } else {
            SKShapeNode *ray_one = (SKShapeNode*)[self childNodeWithName:@"ray1"];
            if (ray_one) {
                UIBezierPath *ray_two_path = [[UIBezierPath alloc] init];
                [ray_two_path moveToPoint:(CGPointMake(0, 0))];
                float x = 0 + 150 * cos(DEGREES_TO_RADIANS(30.0 + self.angle));
                float y = 0 + 150 * sin(DEGREES_TO_RADIANS(30.0 + self.angle));
                
                [ray_two_path addLineToPoint:CGPointMake(x, y)];
                ray_one.path = ray_two_path.CGPath;
                
                ray_one.strokeColor = [SKColor whiteColor];
            }
        }
    }
    
    return (body_one);
}

-(BOOL)checkPathInFront {
    float ray_one_end_x = self.position.x + 200 * cosf(DEGREES_TO_RADIANS(0.0 + self.angle));
    float ray_one_end_y = self.position.y + 200 * sinf(DEGREES_TO_RADIANS(0.0 + self.angle));
    
    SKPhysicsBody *body_one = [self.scene.physicsWorld bodyAlongRayStart:self.position end:CGPointMake(ray_one_end_x, ray_one_end_y)];
    
    if (SHOW_RAYS) {
        if (body_one) {
            NSLog(@"%@", body_one);
            SKShapeNode *ray_one = (SKShapeNode*)[self childNodeWithName:[NSString stringWithFormat:@"ray2"]];
            if (ray_one) {
                UIBezierPath *ray_two_path = [[UIBezierPath alloc] init];
                [ray_two_path moveToPoint:(CGPointMake(0, 0))];
                float x = 0 + 200 * cos(DEGREES_TO_RADIANS(0.0 + self.angle));
                float y = 0 + 200 * sin(DEGREES_TO_RADIANS(0.0 + self.angle));
                
                [ray_two_path addLineToPoint:CGPointMake(x, y)];
                ray_one.path = ray_two_path.CGPath;
                
                ray_one.strokeColor = [SKColor greenColor];
            }
        } else {
            SKShapeNode *ray_one = (SKShapeNode*)[self childNodeWithName:@"ray2"];
            if (ray_one) {
                UIBezierPath *ray_two_path = [[UIBezierPath alloc] init];
                [ray_two_path moveToPoint:(CGPointMake(0, 0))];
                float x = 0 + 200 * cos(DEGREES_TO_RADIANS(0.0 + self.angle));
                float y = 0 + 200 * sin(DEGREES_TO_RADIANS(0.0 + self.angle));
                
                [ray_two_path addLineToPoint:CGPointMake(x, y)];
                ray_one.path = ray_two_path.CGPath;
                
                ray_one.strokeColor = [SKColor whiteColor];
            }
        }
    }
    
    return (body_one);
    
}

@end
