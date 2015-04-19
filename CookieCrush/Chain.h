//
//  Chain.h
//  CookieCrush
//
//  Created by Jonyzfu on 4/16/15.
//  Copyright (c) 2015 Jonyzfu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Cookie;

typedef NS_ENUM(NSUInteger, ChainType) {
    ChainTypeHorizontal,
    ChainTypeVertical,
};


@interface Chain : NSObject

@property(strong, nonatomic, readonly) NSArray *cookies;
@property(assign, nonatomic) ChainType chainType;
@property(assign, nonatomic) NSUInteger score;

- (void)addCookie:(Cookie *)cookie;

@end
