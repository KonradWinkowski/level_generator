//
//  HUD.h
//  level_generator
//
//  Created by Konrad Winkowski on 9/10/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol HUDDelegate;

@interface HUD : SKNode

@property (nonatomic, weak) id<HUDDelegate> delegate;

-(instancetype)initWithSize:(CGSize)scene_size;

-(BOOL)hudTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
-(BOOL)hudTouchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

@end

@protocol HUDDelegate <NSObject>

- (void)didTapStealthKillButton;

@end
