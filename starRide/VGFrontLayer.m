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

        _game = [[VGGameModel alloc] initWithSize:size];
        _game.delegate = self;
        
        _movingLayer = [[CCNode alloc] init];
        _ground = [[VGGround alloc] init];
        _character = [[VGCharacter alloc] init];
        _gameSpeed = 300;

        [self layoutChildren];
    }
    return self;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)layoutChildren {
    [self.movingLayer addChild:self.ground z:0];
    [self.movingLayer addChild:self.character z:1];
    [self addChild:self.movingLayer z:0];
    
    self.character.position = VG_CHARACTER_INIT_POSITION;
}

////////////////////////////////
#pragma mark - Cocos2D
////////////////////////////////

- (void)fixedUpdate:(CCTime)dt {
    [self.game update:dt];
}

- (void)update:(CCTime)dt {
    self.movingLayer.position = CGPointMake(-self.character.position.x + VG_CHARACTER_INIT_POSITION.x, 0);
    
//    self.movingLayer.position = CGPointMake(-self.character.position.x + VG_CHARACTER_INIT_POSITION.x, -self.character.position.y + VG_CHARACTER_INIT_POSITION.y);
}

///////////////////////////////////
#pragma mark - VGGameModel delegate
///////////////////////////////////

///////////////////////////////////
#pragma mark - VGWorldModel delegate
///////////////////////////////////

- (void)characterDidMove:(CGPoint)position angle:(CGFloat)angle {
    [self.character moveCharacterAtPosition:position angle:angle];
}

- (void)didCreateGroundTile:(VGGroundTileModel *)tile atPosition:(CGPoint)position {
    [self.ground createTile:tile atPosition:position];
}

- (void)didRemoveGroundTile:(VGGroundTileModel *)tile {
    [self.ground removeTile:tile];
}


@end
