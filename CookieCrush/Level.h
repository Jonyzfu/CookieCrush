//
//  Level.h
//  CookieCrush
//
//  Created by Jonyzfu on 4/14/15.
//  Copyright (c) 2015 Jonyzfu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cookie.h"
#import "Tile.h"
#import "Swap.h"
#import "Chain.h"

static const NSInteger NumColumns = 9;
static const NSInteger NumRows = 9;

@interface Level : NSObject

@property (assign, nonatomic) NSUInteger targetScore;
@property (assign, nonatomic) NSUInteger maximumMoves;

- (NSSet *)shuffle;
- (Cookie *)cookieAtColumn:(NSInteger)column row:(NSInteger)row;
- (instancetype)initWithFile:(NSString *)filename;
- (Tile *)tileAtColumn:(NSInteger)column row:(NSInteger)row;
- (void)detectPossibleSwaps;
- (void)performSwap:(Swap *)swap;
- (BOOL)isPossibleSwap:(Swap *)swap;
- (NSSet *)removeMatches;
- (NSArray *)fillHoles;
- (NSArray *)topUpCookies;
- (void)resetComboMultiplier;

@end
