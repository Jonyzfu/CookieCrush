//
//  GameScene.m
//  CookieCrush
//
//  Created by Jonyzfu on 4/14/15.
//  Copyright (c) 2015 Jonyzfu. All rights reserved.
//

#import "GameScene.h"
#import "Cookie.h"
#import "Level.h"
#import "Swap.h"

static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface GameScene ()

// This is the container for all the other layers and it’s centered on the screen.  Base Layer
@property(strong, nonatomic) SKNode *gameLayer;
@property(strong, nonatomic) SKNode *cookiesLayer;
@property(strong, nonatomic) SKNode *tilesLayer;

@property(assign, nonatomic) NSInteger swipeFromColumn;
@property(assign, nonatomic) NSInteger swipeFromRow;

@end

@implementation GameScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.anchorPoint = CGPointMake(0.5, 0.5);
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
        [self addChild:background];
        self.swipeFromColumn = self.swipeFromRow = NSNotFound;
        [self preloadResources];
    }
    
    self.gameLayer = [SKNode node];
    [self addChild:self.gameLayer];
    
    CGPoint layerPosition = CGPointMake(-TileWidth * NumColumns / 2, - TileHeight * NumRows / 2);
    
    self.tilesLayer = [SKNode node];
    self.tilesLayer.position = layerPosition;
    [self.gameLayer addChild:self.tilesLayer];
    
    self.cookiesLayer = [SKNode node];
    self.cookiesLayer.position = layerPosition;
    [self.gameLayer addChild:self.cookiesLayer];
    
    self.selectionSprite = [SKSpriteNode node];
    
    return self;
}

- (void)addSpritesForCookies:(NSSet *)cookies {
    for (Cookie *cookie in cookies) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[cookie spriteName]];
        sprite.position = [self pointForColumn:cookie.column row:cookie.row];
        [self.cookiesLayer addChild:sprite];
        cookie.sprite = sprite;
    }
}

- (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
    return CGPointMake(column * TileWidth + TileWidth / 2, row * TileHeight + TileHeight / 2);
}

- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row {
    NSParameterAssert(column);
    NSParameterAssert(row);
    
    // If this is a valid location within the cookie layer, then calculate the corresponding row and column numbers
    if (point.x >= 0 && point.x < NumColumns * TileWidth &&
        point.y >= 0 && point.y < NumRows * TileHeight) {
        *column = point.x / TileWidth;
        *row = point.y / TileHeight;
        return YES;
    } else {
        *column = NSNotFound;
        *row = NSNotFound;
        return NO;
    }
}

- (void)addTiles {
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            if ([self.level tileAtColumn:column row:row] != nil) {
                SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithImageNamed:@"Tile"];
                tileNode.position = [self pointForColumn:column row:row];
                [self.tilesLayer addChild:tileNode];
            }
        }
    }
}

#pragma mark - Highlighted Selection
- (void)showSelectionIndicatorForCookie:(Cookie *)cookie {
    // If the selection indicator is still visible, then first remove it
    if (self.selectionSprite.parent != nil) {
        [self.selectionSprite removeFromParent];
    }
    
    SKTexture *texture = [SKTexture textureWithImageNamed:[cookie highlightedSpriteName]];
    self.selectionSprite.size = texture.size;
    [self.selectionSprite runAction:[SKAction setTexture:texture]];
    
    [cookie.sprite addChild:self.selectionSprite];
    self.selectionSprite.alpha = 1.0;
}

- (void)hideSelectionIndicator {
    [self.selectionSprite runAction:[SKAction sequence:@[
        [SKAction fadeOutWithDuration:0.3],
        [SKAction removeFromParent]]]];
}

#pragma mark - Swipe methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Convert the touch location to a point relative to cookiesLayer
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.cookiesLayer];
    
    // If the touch is inside a square on the level grid, then start the swipe motion
    NSInteger column, row;
    if ([self convertPoint:location toColumn:&column row:&row]) {
        
        // Verify the touch is on a cookie rather than on an empty square
        Cookie *cookie = [self.level cookieAtColumn:column row:row];
        if (cookie != nil) {
            
            // Record the column and row where the swipe started
            self.swipeFromColumn = column;
            self.swipeFromRow = row;
            
            [self showSelectionIndicatorForCookie:cookie];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.swipeFromColumn == NSNotFound) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.cookiesLayer];
    
    NSInteger column, row;
    if ([self convertPoint:location toColumn:&column row:&row]) {
        // Figure out the direction of the player's swipe by comparing the new column and
        // row numbers to the previous ones
        NSInteger horzDelta = 0, vertDelta = 0;
        if (column < self.swipeFromColumn) {
            horzDelta = -1;
        } else if (column > self.swipeFromColumn) {
            horzDelta = 1;
        } else if (row < self.swipeFromRow) {
            vertDelta = -1;
        } else if (row > self.swipeFromRow) {
            vertDelta = 1;
        }
        
        // perfroms the swap if the player swiped out of the old square
        if (horzDelta != 0 || vertDelta != 0) {
            [self trySwapHorizontal:horzDelta vertical:vertDelta];
            
            [self hideSelectionIndicator];
            
            // the game will ignore the rest of this swipe motion
            self.swipeFromColumn = NSNotFound;
        }
    }
}

- (void)trySwapHorizontal:(NSInteger)horzDelta vertical:(NSInteger)vertDelta {
    // Calculate the column and row numbers of the cookie to swap with
    NSInteger toColumn = self.swipeFromColumn + horzDelta;
    NSInteger toRow = self.swipeFromRow + vertDelta;
    
    // When the user swipes from a cookie near the edge of the grid.
    if (toColumn < 0 || toColumn >= NumColumns) {
        return;
    }
    if (toRow < 0 || toRow >= NumRows) {
        return;
    }
    
    // Check there is actually a cookie at the new position
    Cookie *toCookie = [self.level cookieAtColumn:toColumn row:toRow];
    if (toCookie == nil) {
        return;
    }
    
    // Log both cookies to debug pane
    Cookie *fromCookie = [self.level cookieAtColumn:self.swipeFromColumn row:self.swipeFromRow];
    
    if (self.swipeHandler != nil) {
        Swap *swap = [[Swap alloc] init];
        swap.cookieA = fromCookie;
        swap.cookieB = toCookie;
        self.swipeHandler(swap);
    }
}

- (void)animateSwap:(Swap *)swap completion:(dispatch_block_t)completion {
    // Put the cookie you started with on top
    swap.cookieA.sprite.zPosition = 100;
    swap.cookieB.sprite.zPosition = 90;
    
    const NSTimeInterval duration = 0.3;
    
    SKAction *moveA = [SKAction moveTo:swap.cookieB.sprite.position duration:duration];
    moveA.timingMode = SKActionTimingEaseOut;
    [swap.cookieA.sprite runAction:[SKAction sequence:@[moveA, [SKAction runBlock:completion]]]];
    
    SKAction *moveB = [SKAction moveTo:swap.cookieA.sprite.position duration:duration];
    moveB.timingMode = SKActionTimingEaseOut;
    [swap.cookieB.sprite runAction:moveB];
    [self runAction:self.swapSound];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.swipeFromColumn = self.swipeFromRow = NSNotFound;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

- (void)animateInvalidSwap:(Swap *)swap completion:(dispatch_block_t)completion {
    swap.cookieA.sprite.zPosition = 100;
    swap.cookieB.sprite.zPosition = 90;
    
    const NSTimeInterval duration = 0.2;
    
    SKAction *moveA = [SKAction moveTo:swap.cookieB.sprite.position duration:duration];
    moveA.timingMode = SKActionTimingEaseOut;
    
    SKAction *moveB = [SKAction moveTo:swap.cookieA.sprite.position duration:duration];
    moveB.timingMode = SKActionTimingEaseOut;
    
    [swap.cookieA.sprite runAction:[SKAction sequence:@[moveA, moveB, [SKAction runBlock:completion]]]];
    [swap.cookieB.sprite runAction:[SKAction sequence:@[moveB, moveA]]];
    [self runAction:self.invalidSwapSound];
}

#pragma mark - Sounds Effection
- (void)preloadResources {
    self.swapSound = [SKAction playSoundFileNamed:@"Chomp.wav" waitForCompletion:NO];
    self.invalidSwapSound = [SKAction playSoundFileNamed:@"Error.wav" waitForCompletion:NO];
    self.matchSound = [SKAction playSoundFileNamed:@"Ka-Ching.wav" waitForCompletion:NO];
    self.fallingCookieSound = [SKAction playSoundFileNamed:@"Scrape.wav" waitForCompletion:NO];
    self.addCookieSound = [SKAction playSoundFileNamed:@"Drip.wav" waitForCompletion:NO];
}



@end
