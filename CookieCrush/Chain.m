//
//  Chain.m
//  CookieCrush
//
//  Created by Jonyzfu on 4/16/15.
//  Copyright (c) 2015 Jonyzfu. All rights reserved.
//

#import "Chain.h"

@implementation Chain {
    // Only read from it
    NSMutableArray *_cookies;
}

- (void)addCookie:(Cookie *)cookie {
    if (_cookies == nil) {
        _cookies = [NSMutableArray array];
    }
    [_cookies addObject:cookie];
}

- (NSArray *)cookies {
    return _cookies;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type: %ld cookies: %@", (long)self.chainType, self.cookies];
}

@end
