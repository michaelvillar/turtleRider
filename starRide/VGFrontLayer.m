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
#import "VGGameModel.h"

#import "cocos2d.h"


@interface VGFrontLayer ()

@property (strong, readonly) VGGameModel* game;
@property (strong, readwrite) CCNode* movingLayer;
@property (strong, readwrite) VGGround* ground;
@property (strong, readwrite) VGCharacter* character;
@property (assign, readwrite) CGFloat gameSpeed;


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

        _game = [[VGGameModel alloc] init];
        _movingLayer = [[CCNode alloc] init];
        _ground = [[VGGround alloc] initWithWorld:_game.world];
        _character = [[VGCharacter alloc] init];
        _gameSpeed = 300;
        
        [_movingLayer addChild:_ground z:0];
        [_movingLayer addChild:_character z:1];
        [self addChild:_movingLayer z:0];
        
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

- (void)fixedUpdate:(CCTime)dt {
    [self.game.world update:dt];
}

- (void)update:(CCTime)dt {
    self.character.position = self.game.world.characterPosition;
    self.movingLayer.position = CGPointMake(-self.character.position.x + VG_CHARACTER_INIT_POSITION.x, 0);
}

@end
