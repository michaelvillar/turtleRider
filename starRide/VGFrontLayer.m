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
@property (strong, readwrite) NSMutableDictionary* actions;

- (void)layoutChildren;
- (void)updateActions;
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
        _actions = [[NSMutableDictionary alloc] init];

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

- (void)updateActions {
    for (NSString* key in self.actions) {
        NSDictionary* dic = self.actions[key];
        if ([key isEqualToString:@"characterDidMove"]) {
            [self.character moveCharacterAtPosition:((NSValue*)dic[@"position"]).CGPointValue angle:((NSNumber*)dic[@"angle"]).floatValue];
        } else if ([key isEqualToString:@"didCreateGroundTile"]) {
            [self.ground createTile:dic[@"tile"] atPosition:((NSValue*)dic[@"position"]).CGPointValue];
        } else if ([key isEqualToString:@"didRemoveGroundTile"]) {
            [self.ground removeTile:dic[@"tile"]];
        } else {
            NSLog(@"invalid action");
        }
    }
    self.actions = [[NSMutableDictionary alloc] init];
}

////////////////////////////////
#pragma mark - Cocos2D
////////////////////////////////

- (void)fixedUpdate:(CCTime)dt {
    [self.game update:dt];
}

- (void)update:(CCTime)dt {
    [self updateActions];
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
    NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                         [NSValue valueWithCGPoint:position], @"position",
                         @(angle), @"angle", nil];
    self.actions[@"characterDidMove"] = dic;
}

- (void)didCreateGroundTile:(VGGroundTileModel *)tile atPosition:(CGPoint)position {
    NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                         tile, @"tile",
                         [NSValue valueWithCGPoint:position], @"position", nil];
    self.actions[@"didCreateGroundTile"] = dic;
}

- (void)didRemoveGroundTile:(VGGroundTileModel *)tile {
    NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                         tile, @"tile", nil];
    self.actions[@"didRemoveGroundTile"] = dic;
}


@end
