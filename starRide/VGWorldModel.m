//
//  VGWorldModel.m
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGWorldModel.h"
#import "VGCharacterModel.h"
#import "VGGameModel.h"
#import "VGGroundModel.h"
#import "VGConstant.h"

@interface VGWorldModel ()
@property (strong, readonly) VGCharacterModel* character;
@property (strong, readonly) VGGroundModel* ground;
@property (assign, readonly) CGFloat travelledXDistance;

- (void)moveCharacter:(CGFloat)distance;
@end

@implementation VGWorldModel

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithGame:(VGGameModel*)game {
    self = [super init];
    if (self) {
        _game = game;
        _ground = [[VGGroundModel alloc] init];
        _ground.delegate = self;
        _character = [[VGCharacterModel alloc] init];
    }
    return self;
}

- (void)update:(CCTime)dt {
    [self.ground update:dt travelledXDistance:self.travelledXDistance];
    [self moveCharacter:self.game.speed * dt];
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (CGFloat)travelledXDistance {
    return self.character.position.x - VG_CHARACTER_INIT_POSITION.x;
}

- (void)moveCharacter:(CGFloat)distance {
    NSDictionary* dic = [self.ground nextPositionInfo:distance];
    if (((NSNumber*)dic[@"positionFound"]).boolValue) {
        //On curve
        self.character.position = ((NSValue*)dic[@"position"]).CGPointValue;
    } else {
        //Falling
        self.character.position = ((NSValue*)dic[@"position"]).CGPointValue;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(characterDidMove:angle:)]) {
        [self.delegate characterDidMove:self.character.position angle:0];
    }
}

///////////////////////////////////
#pragma mark - VGGroundModelDelegate delegate
///////////////////////////////////

- (void)didCreateGroundTile:(VGGroundTileModel*)tile atPosition:(CGPoint)position {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRemoveGroundTile:)]) {
        [self.delegate didCreateGroundTile:tile atPosition:position];
    }
}

- (void)didRemoveGroundTile:(VGGroundTileModel*)tile {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRemoveGroundTile:)]) {
        [self.delegate didRemoveGroundTile:tile];
    }
}

@end