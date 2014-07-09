//
//  VGGameScene.m
//  starRide
//
//  Created by Sebastien Villar on 08/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGameScene.h"
#import "VGFrontLayer.h"
#import "VGBackLayer.h"

@interface VGGameScene ()
@property (strong, readonly) VGFrontLayer* frontLayer;
@property (strong, readonly) VGBackLayer* backLayer;
@end

@implementation VGGameScene

////////////////////////////////
#pragma mark - Public
////////////////////////////////

+ (VGGameScene*)scene {
    return [[self alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        _backLayer = [[VGBackLayer alloc] initWithSize:self.contentSize];
        _frontLayer = [[VGFrontLayer alloc] initWithSize:self.contentSize];
        
        [self addChild:_backLayer z:0];
        [self addChild:_frontLayer z:1];
    }
    return self;
}

- (void)dealloc {
}

////////////////////////////////
#pragma mark - Cocos2D
////////////////////////////////

- (void)onEnter {
    [super onEnter];
}


- (void)onExit {
    [super onExit];
}


@end
