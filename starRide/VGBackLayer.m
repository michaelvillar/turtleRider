//
//  VGBackLayer.m
//  starRide
//
//  Created by Sebastien Villar on 08/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGBackLayer.h"

#import "cocos2d.h"

@implementation VGBackLayer

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithSize:(CGSize)size {
    self = [super init];
    if (self) {
        self.contentSize = size;
        CCNodeColor* nodeColor = [[CCNodeColor alloc] initWithColor:[CCColor colorWithWhite:1.0 alpha:1.0]];
        nodeColor.contentSize = self.contentSize;
        [self addChild:nodeColor];
    }
    return self;
}

////////////////////////////////
#pragma mark - Cocos2D
////////////////////////////////

- (void)update:(CCTime)dt {
}

@end
