//
//  Swap.m
//  CookieCrush
//
//  Created by Jonyzfu on 4/15/15.
//  Copyright (c) 2015 Jonyzfu. All rights reserved.
//

#import "Swap.h"
#import "Cookie.h"

@implementation Swap

- (BOOL)isEqual:(id)object {
    // Only compare this object against other Swap objects.
    if (![object isKindOfClass:[Swap class]]) {
        return NO;
    }
    // Two swaps are equal if they contain the same cookie
    Swap *other = (Swap *)object;
    return (other.cookieA == self.cookieA && other.cookieB == self.cookieB) ||
    (other.cookieB == self.cookieA && other.cookieA == self.cookieB);
}

- (NSUInteger)hash {
    return [self.cookieA hash] ^ [self.cookieB hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ swap %@ with %@", [super description], self.cookieA, self.cookieB];
}

@end
