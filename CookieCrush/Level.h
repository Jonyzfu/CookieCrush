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

static const NSInteger NumColumns = 9;
static const NSInteger NumRows = 9;

@interface Level : NSObject

- (NSSet *)shuffle;
- (Cookie *)cookieAtColumn:(NSInteger)column row:(NSInteger)row;
- (instancetype)initWithFile:(NSString *)filename;
- (Tile *)tileAtColumn:(NSInteger)column row:(NSInteger)row;
- (void)performSwap:(Swap *)swap;

@end
