//
//  GameScene.h
//  CookieCrush
//

//  Copyright (c) 2015 Jonyzfu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class Level;
@class Swap;

@interface GameScene : SKScene

@property(strong, nonatomic) Level *level;

// This is how it communicates back to the GameViewCongtroller
@property(copy, nonatomic) void (^swipeHandler)(Swap *swap);

@property(strong, nonatomic) SKSpriteNode *selectionSprite;

- (void)addSpritesForCookies:(NSSet *)cookies;
- (void)addTiles;
- (void)animateSwap:(Swap *)swap completion:(dispatch_block_t)completion;

@end
