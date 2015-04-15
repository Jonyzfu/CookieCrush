//
//  GameScene.h
//  CookieCrush
//

//  Copyright (c) 2015 Jonyzfu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class Level;

@interface GameScene : SKScene

@property(strong, nonatomic) Level *level;

- (void)addSpritesForCookies:(NSSet *)cookies;

@end
