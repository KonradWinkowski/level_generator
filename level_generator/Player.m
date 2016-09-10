//
//  Player.m
//  CellularAutomataFinal
//
//  Created by Kim Pedersen on 18/02/14.
//  Copyright (c) 2014 Kim Pedersen. All rights reserved.
//

#import "Player.h"

@implementation Player

- (instancetype)initWithTexture:(SKTexture *)texture
{
    if ((self = [super initWithTexture:texture])) {
        self.desiredPosition = self.position;
        
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"tiles"];
        
        self.playerIdleAnimationFrames = @[[atlas textureNamed:@"hero_idle_1"],
                                           [atlas textureNamed:@"hero_idle_2"]];
        
        self.playerWalkAnimationFrames = @[[atlas textureNamed:@"hero_run_1"],
                                           [atlas textureNamed:@"hero_run_2"],
                                           [atlas textureNamed:@"hero_run_3"],
                                           [atlas textureNamed:@"hero_run_4"]];
        
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.categoryBitMask = category_player;
        self.physicsBody.collisionBitMask = category_wall;
        self.physicsBody.allowsRotation = NO;
        
        self.melleAttackkNode = [[SKSpriteNode alloc] initWithColor:[SKColor orangeColor] size:CGSizeMake(self.size.width, self.size.height * 1.5)];
        self.melleAttackkNode.zPosition = 4;
        self.melleAttackkNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.melleAttackkNode.size];
        self.melleAttackkNode.physicsBody.categoryBitMask = category_melee;
        self.melleAttackkNode.physicsBody.contactTestBitMask = category_enemy;
        self.melleAttackkNode.physicsBody.dynamic = NO;
        self.melleAttackkNode.position = CGPointMake(self.melleAttackkNode.size.width, 0);
        [self addChild:self.melleAttackkNode];
    }
    return self;
}

-(void)update:(CFTimeInterval)currentTime {
    
    //    if (self.xScale > 0) {
    self.melleAttackkNode.position = CGPointMake(self.melleAttackkNode.size.width, 0);
    //    } else {
    //        self.melleAttackkNode.position = CGPointMake(0 - self.melleAttackkNode.size.width, 0);
    //    }
    
    //    NSMutableArray *points = [NSMutableArray new];
    //    NSMutableArray *nearByBlocks = [NSMutableArray new];
    //    
    //    CGPoint rectOffset = CGPointMake(self.position.x + 40, self.position.y - 200);
    //    CGRect rect = CGRectMake(rectOffset.x, rectOffset.y, 300, 400);
    //    
    //    [self.scene.physicsWorld enumerateBodiesInRect:rect usingBlock:^(SKPhysicsBody * _Nonnull body, BOOL * _Nonnull stop) {
    //        NSLog(@"%@",body.node.name);
    //        [nearByBlocks addObject:body];
    //    }];
    //    
    //    NSMutableArray *hitBlocks = [NSMutableArray new];
    //    
    //    for (SKPhysicsBody *body in nearByBlocks) {
    //        
    //        //        CGPoint point = CGPointMake(CGRectGetMinX(body.node.frame), CGRectGetMinY(body.node.frame));
    //        
    //        //        float ray_one_end_x = self.position.x + 150 * cosf(DEGREES_TO_RADIANS(i));
    //        //        float ray_one_end_y = self.position.y + 150 * sinf(DEGREES_TO_RADIANS(i));
    //        
    //        SKPhysicsBody *hit_body = [self.scene.physicsWorld bodyAlongRayStart:self.position end:body.node.position];
    //        
    //        if (hit_body && ![hitBlocks containsObject:hit_body]) {
    //            [hitBlocks addObject:hit_body];
    //        }
    //    }
    //    
    //    for (SKPhysicsBody *body in hitBlocks) {
    //        CGPoint point = CGPointMake(CGRectGetMinX(body.node.frame), CGRectGetMinY(body.node.frame));
    //        
    //        [self.scene.physicsWorld enumerateBodiesAlongRayStart:self.position end:point usingBlock:^(SKPhysicsBody * _Nonnull body, CGPoint point, CGVector normal, BOOL * _Nonnull stop) {
    //            CGPoint converted = [self convertPoint:point fromNode:self.scene];
    //            [points addObject:[NSValue valueWithCGPoint:converted]];
    //        }];
    //    }
    //    
    //    [points sortUsingComparator:^NSComparisonResult(NSValue   * _Nonnull obj1, NSValue   * _Nonnull obj2) {
    //        CGPoint point1 = [obj1 CGPointValue];
    //        CGPoint point2 = [obj2 CGPointValue];
    //        
    //        return point1.y < point2.y;
    //    }];
    //    
    //    [[self childNodeWithName:@"line"] removeFromParent];
    //    
    //    SKShapeNode *line = [SKShapeNode new];
    //    UIBezierPath *path = [UIBezierPath new];
    //    [path moveToPoint:CGPointZero];
    //    
    //    for (NSValue *val in points){
    //        [path addLineToPoint:[val CGPointValue]];
    //    }
    //    
    //    line.path = path.CGPath;
    //    line.strokeColor = [SKColor redColor];
    //    line.fillColor = [SKColor redColor];
    //    line.name = @"line";
    //    
    //    [self addChild:line];
}

-(CGRect)meleeAttackBox{
    
    CGRect box = self.melleAttackkNode.frame;
    box.origin.y = self.position.y - box.size.height / 2;
    box.origin.x = (self.xScale > 0) ? self.position.x + self.size.width / 2 : self.position.x - box.size.width;
    
    return box;
}

- (CGRect)boundingRect
{
    return CGRectMake(self.desiredPosition.x - (CGRectGetWidth(self.frame) / 2),
                      self.desiredPosition.y - (CGRectGetHeight(self.frame) / 2),
                      CGRectGetWidth(self.frame),
                      CGRectGetHeight(self.frame));
}

- (void)resolveAnimationWithID:(NSUInteger)animationID
{
    NSString *animationKey = nil;
    NSArray *animationFrames = nil;
    CGFloat animationSpeed = 0.0f;
    
    switch (animationID)
    {
        case 0:
        // Idle
        animationKey = @"anim_idle";
        animationFrames = self.playerIdleAnimationFrames;
        animationSpeed = 10.0f;
        break;
        
        default:
        // Walk
        animationKey = @"anim_walk";
        animationFrames = self.playerWalkAnimationFrames;
        animationSpeed = 5.0f;
        break;
    }
    
    SKAction *animAction = [self actionForKey:animationKey];
    
    // If this animation is already running or there are no frames we exit
    if (animAction || [animationFrames count] < 1) {
        return;
    }
    
    animAction = [SKAction animateWithTextures:animationFrames timePerFrame:animationSpeed/60.0f resize:YES restore:NO];
    
    if (animationID == 1) {
        // Append sound for walking
        //        animAction = [SKAction group:@[animAction, [SKAction playSoundFileNamed:@"step.wav" waitForCompletion:NO]]];
    }
    
    [self runAction:animAction withKey:animationKey];
}

@end
