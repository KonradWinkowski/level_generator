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

// Player movement constant
static const CGFloat kPlayerMovementSpeed = 100.0f;

@interface GameScene()

@property (nonatomic, strong) KWLevel *level;
@property (assign, nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (strong, nonatomic) DPad *dPad;
@property (assign, nonatomic) BOOL isExitingLevel;

@end

@implementation GameScene

-(instancetype)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        // Background color
        self.backgroundColor = [SKColor colorWithRed:88.0f/255.0f green:90.0f/255.0f blue:103.0f/255.0f alpha:1.0f];
        
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        
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
        
        // HUD
        SKNode *hud = [SKNode node];
        hud.name = @"hud";
        hud.zPosition = 10;
        
        // Dpad
        _dPad = [[DPad alloc] initWithRect:CGRectMake(0, 0, 64.0f, 64.0f)];
        _dPad.name = @"dpad";
        _dPad.position = CGPointMake(64.0f / 4.0f, 64.0f / 4.0f);
        _dPad.numberOfDirections = 24;
        _dPad.deadRadius = 8.0f;
        [hud addChild:self.dPad];
        
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
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
    
    if (velocity.x != 0 && velocity.y != 0) {
        // Calculate the desired position for the player
        self.player.desiredPosition = CGPointMake(self.player.position.x + velocity.x * timeSinceLast * kPlayerMovementSpeed, self.player.position.y + velocity.y * timeSinceLast * kPlayerMovementSpeed);
        
        // Insert code to detect collision between player and walls here
        
        // Insert code to detect if player reached exit or found treasure here
    }
    
    if (velocity.x != 0.0f) {
        self.player.xScale = (velocity.x > 0.0f) ? 1.0f : -1.0f;
    }
    
    // Ensure correct animation is playing
    self.player.playerAnimationID = (velocity.x != 0.0f) ? 1 : 0;
    [self.player resolveAnimationWithID:self.player.playerAnimationID];
    
    // Move the player to the desired position
    self.player.position = self.player.desiredPosition;
    
    self.camera.position = self.player.position;
    
    [self hud].position = self.camera.position;
    
}

@end
