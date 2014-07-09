//
//  VGCharacter.m
//  starRide
//
//  Created by Sebastien Villar on 08/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGCharacter.h"

@implementation VGCharacter

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)init {
    self = [super init];
    if (self) {
        CGPoint points[] = {
            CGPointMake(0, 0),
            CGPointMake(50, 0),
            CGPointMake(50, 25),
            CGPointMake(0, 25)
        };
        [self drawPolyWithVerts:points
                          count:4
                      fillColor:nil
                    borderWidth:1
                    borderColor:[CCColor colorWithWhite:0 alpha:1]];
        self.contentSize = CGSizeMake(50, 25);
        self.anchorPoint = CGPointMake(0.5, 1.0);
    }
    return self;
}

////////////////////////////////
#pragma mark - Cocos2D
////////////////////////////////

@end
