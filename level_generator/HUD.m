//
//  HUD.m
//  level_generator
//
//  Created by Konrad Winkowski on 9/10/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import "HUD.h"

@implementation HUD
{
    CGSize size;
}

-(instancetype)initWithSize:(CGSize)scene_size {
    if (self = [super init]) {
        self.name = @"hud";
        size = scene_size;
        [self addStealthKillButton];
    }
    return self;
}

-(void)addStealthKillButton {
    
    SKSpriteNode *stealthButton = [SKSpriteNode spriteNodeWithColor:[SKColor blueColor] size:CGSizeMake(32, 32)];
    stealthButton.name = @"stealth_button";
    stealthButton.position = CGPointMake(size.width / 2 - 40, size.height / 2 - 40);
    [self addChild:stealthButton];
}

-(BOOL)hudTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"stealth_button"]) {
        [self.delegate didTapStealthKillButton];
        
        return YES;
    }
    
    return NO;
}

-(BOOL)hudTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint location = [[touches anyObject] locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"stealth_button"]) {
        return YES;
    }
    
    return NO;
}

@end
