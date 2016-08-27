//
//  GameScene.m
//  level_generator
//
//  Created by Konrad Winkowski on 8/24/16.
//  Copyright (c) 2016 KonradWinkowski. All rights reserved.
//

#import "GameScene.h"
#import "KWLevel.h"
#import "Player.h"
#import "DPad.h"
#import "EnemyObject.h"

// Player movement constant
static const CGFloat kPlayerMovementSpeed = 100.0f;

@interface GameScene() <SKPhysicsContactDelegate>

@property (nonatomic, strong) KWLevel *level;
@property (assign, nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (strong, nonatomic) DPad *dPad;
@property (assign, nonatomic) BOOL isExitingLevel;

@property (nonatomic, strong) EnemyObject *enemy;

@property (nonatomic, strong) NSArray *enemies;

@property (nonatomic, strong) SKSpriteNode *melleAttackkNode;

@end

@implementation GameScene

-(instancetype)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        // Background color
        self.backgroundColor = [SKColor colorWithRed:88.0f/255.0f green:90.0f/255.0f blue:103.0f/255.0f alpha:1.0f];
        
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        self.physicsWorld.contactDelegate = self;
        
        // World node
        SKNode *world = [SKNode new];
        world.name = @"world";
        world.zPosition = 1;
        [self addChild:world];
        
        SKCameraNode *camera = [SKCameraNode new];
        camera.name = @"camera";
        self.camera = camera;
        [[self world] addChild:camera];
        
        // Add code to generate new cave here
        
        
        // Add Player
        Player *player = [Player spriteNodeWithTexture:[[SKTextureAtlas atlasNamed:@"tiles"] textureNamed:@"hero_idle_1"]];
        player.name = @"player";
        player.zPosition = 3;
        player.desiredPosition = CGPointZero;
        [world addChild:player];
        
        self.melleAttackkNode = [[SKSpriteNode alloc] initWithColor:[SKColor orangeColor] size:CGSizeMake(player.size.width, player.size.height * 1.5)];
        self.melleAttackkNode.zPosition = 4;
        self.melleAttackkNode.position = player.desiredPosition;
        self.melleAttackkNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.melleAttackkNode.size];
        self.melleAttackkNode.physicsBody.categoryBitMask = category_melee;
        self.melleAttackkNode.physicsBody.contactTestBitMask = category_enemy;
        self.melleAttackkNode.physicsBody.dynamic = NO;
        [world addChild:self.melleAttackkNode];
        
        
        // HUD
        SKNode *hud = [SKNode node];
        hud.name = @"hud";
        hud.zPosition = 10;
        
        // Dpad
        _dPad = [[DPad alloc] initWithRect:CGRectMake(0, 0, 64.0f, 64.0f)];
        _dPad.name = @"dpad";
        //        _dPad.position = CGPointMake(-(size.width / 2.0) + 10, -(size.height / 2.0) + 10);
        _dPad.numberOfDirections = 24;
        _dPad.deadRadius = 8.0f;
        //        [hud addChild:self.dPad];
        
        // Add the HUD and World nodes to the scene
        [self addChild:hud];
    }
    
    return self;
}

-(void)didMoveToView:(SKView *)view {
    
    SKNode *world = [SKNode new];
    world.name = @"world";
    world.zPosition = 1;
    [self addChild:world];
    
    _level = [[KWLevel alloc] initWithLevelSize:CGSizeMake(35, 35)];
    _level.name = @"level";
    _level.zPosition = 2;
    [_level generateWithSeed:2];
    [[self world] addChild:_level];
    
    NSMutableArray *temp = [NSMutableArray new];
    
    for (int i = 0; i < 50; i++){
        EnemyObject *enemy = [EnemyObject basicEnemy];
        enemy.name = @"enemy";
        enemy.zPosition = 3;
        enemy.position = [_level randomPositionInMainPlayArea];
        [world addChild:enemy];
        [temp addObject:enemy];
    }
    
    self.enemies = [NSArray arrayWithArray:temp];
    
    [self player].desiredPosition = [_level randomPositionInMainPlayArea];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    CGPoint screenLocation = [touch locationInView:self.view];
    CGPoint touchLocation = [touch locationInNode:[self hud]];
    
    if (screenLocation.x < self.view.frame.size.width / 2.0 && !_dPad.parent){
        _dPad.position = CGPointMake(touchLocation.x - _dPad.joystickRadius, touchLocation.y - _dPad.joystickRadius);
        [[self hud]addChild:_dPad];
        [_dPad touchesBegan:touches withEvent:event];
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_dPad touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_dPad removeFromParent];
    [_dPad touchesEnded:touches withEvent:event];
}

-(Player*)player {
    return (Player*)[[self world] childNodeWithName:@"player"];
}

-(SKNode*)hud {
    return [self childNodeWithName:@"hud"];
}

-(SKNode*)world {
    return [self childNodeWithName:@"world"];
}

-(void)update:(CFTimeInterval)currentTime {
    
    // Calculate the time since last update
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    
    self.lastUpdateTimeInterval = currentTime;
    
    if (timeSinceLast > 1) {
        timeSinceLast = 1.0f / 60.0f;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    CGPoint velocity = self.isExitingLevel ? CGPointZero : self.dPad.velocity;
    
    //    self.enemy.velocity = CGVectorMake(velocity.x, velocity.y);
    
    if (velocity.x != 0 && velocity.y != 0) {
        // Calculate the desired position for the player
        self.player.desiredPosition = CGPointMake(self.player.position.x + velocity.x * timeSinceLast * kPlayerMovementSpeed, self.player.position.y + velocity.y * timeSinceLast * kPlayerMovementSpeed);
        
        // Insert code to detect collision between player and walls here
        
        // Insert code to detect if player reached exit or found treasure here
    }
    
    for (EnemyObject *enemy in self.enemies){
        [enemy update:currentTime];
        //        self.camera.position = enemy.position;
        
        //        [self hud].position = self.camera.position;
    }
    
    if (velocity.x != 0.0f) {
        self.player.xScale = (velocity.x > 0.0f) ? 1.0f : -1.0f;
    }
    
    if (self.player.xScale > 0) {
        self.melleAttackkNode.position = CGPointMake(self.player.position.x + self.melleAttackkNode.size.width, self.player.position.y);
    } else {
        self.melleAttackkNode.position = CGPointMake(self.player.position.x - self.melleAttackkNode.size.width, self.player.position.y);
    }
    
    // Ensure correct animation is playing
    self.player.playerAnimationID = (velocity.x != 0.0f) ? 1 : 0;
    [self.player resolveAnimationWithID:self.player.playerAnimationID];
    
    // Move the player to the desired position
    self.player.position = self.player.desiredPosition;
    
    self.camera.position = self.player.position;
    
    [self hud].position = self.camera.position;
    
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *body1 = contact.bodyA;
    SKPhysicsBody *body2 = contact.bodyB;
    
    if ((body1.categoryBitMask & category_melee) != 0 && (body2.categoryBitMask & category_enemy) != 0) {
        NSLog(@"IS IN RANGE OF MELEE ATTACK");
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *body1 = contact.bodyA;
    SKPhysicsBody *body2 = contact.bodyB;
    
    if ((body1.categoryBitMask & category_melee) != 0 && (body2.categoryBitMask & category_enemy) != 0) {
        NSLog(@"IS OUT OF RANGE OF MELEE ATTACK");
    }
}

@end
