//
//  BasicObject.h
//  level_generator
//
//  Created by Konrad Winkowski on 8/26/16.
//  Copyright © 2016 KonradWinkowski. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define kTileSize 40

static const uint32_t category_wall         =  0x1 << 0;
static const uint32_t category_player       =  0x1 << 1;
static const uint32_t category_enemy        =  0x1 << 2;
static const uint32_t category_item         =  0x1 << 3;
static const uint32_t category_exit         =  0x1 << 4;

@interface BasicObject : SKSpriteNode

@end
