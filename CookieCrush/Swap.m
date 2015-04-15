//
//  Swap.m
//  CookieCrush
//
//  Created by Jonyzfu on 4/15/15.
//  Copyright (c) 2015 Jonyzfu. All rights reserved.
//

#import "Swap.h"

@implementation Swap

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ swap %@ with %@", [super description], self.cookieA, self.cookieB];
}

@end
