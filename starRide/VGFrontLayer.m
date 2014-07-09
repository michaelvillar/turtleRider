//
//  VGFrontLayer.m
//  starRide
//
//  Created by Sebastien Villar on 08/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGFrontLayer.h"
#import "VGConstant.h"
#import "VGGround.h"
#import "VGCharacter.h"

#import "cocos2d.h"


@interface VGFrontLayer ()
@property (strong, readwrite) VGGround* ground;
@property (strong, readwrite) VGCharacter* character;

- (void)layoutChildren;
@end

@implementation VGFrontLayer

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithSize:(CGSize)size {
    self = [super init];
    if (self) {
        self.contentSize = size;
        self.positionType = CCPositionTypeMake(CCPositionUnitPoints,
                                               CCPositionUnitPoints,
                                               CCPositionReferenceCornerBottomLeft);

        _ground = [[VGGround alloc] init];
        _character = [[VGCharacter alloc] init];
        
        [self addChild:_ground z:0];
        [self addChild:_character z:1];
        
        [self layoutChildren];
    }
    return self;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)layoutChildren {
    self.character.position = VG_CHARACTER_INIT_POSITION;
}

////////////////////////////////
#pragma mark - Cocos2D
////////////////////////////////

- (void)update:(CCTime)dt {
}

@end
