//
//  Level.m
//  CookieCrush
//
//  Created by Jonyzfu on 4/14/15.
//  Copyright (c) 2015 Jonyzfu. All rights reserved.
//

#import "Level.h"

@implementation Level

Cookie *_cookies[NumColumns][NumRows];

- (Cookie *)cookieAtColumn:(NSInteger)column row:(NSInteger)row {
    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
    
    return _cookies[column][row];
}

- (NSSet *)shuffle {
    return [self createInitialCookies];
}

- (NSSet *)createInitialCookies {
    NSMutableSet *set = [NSMutableSet set];
    
    // column 0, row 0 is in the bottom-left corner of 2-D grid
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            // Pick a random cookie type
            NSUInteger cookieType = arc4random_uniform(NumCookieTypes) + 1;
            
            // Create a new Cookie object and adds it to the 2-D array
            Cookie *cookie = [self createCookieAtColumn:column row:row withType:cookieType];
            
            [set addObject:cookie];
        }
    }
    return set;
}

- (Cookie *)createCookieAtColumn:(NSInteger)column row:(NSInteger)row withType:(NSUInteger)cookieType {
    Cookie *cookie = [[Cookie alloc] init];
    cookie.cookieType = cookieType;
    cookie.column = column;
    cookie.row = row;
    _cookies[column][row] = cookie;
    return cookie;
}

@end
