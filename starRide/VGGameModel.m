//
//  VGWorldModel.m
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGameModel.h"
#import "VGCharacterModel.h"
#import "VGGroundModel.h"
#import "VGConstant.h"

@interface VGGameModel ()
@property (assign, readwrite) CGFloat speed;
@property (strong, readonly) VGCharacterModel* character;
@property (strong, readonly) VGGroundModel* ground;
@property (assign, readonly) CGFloat travelledXDistance;

- (void)moveCharacter:(CGFloat)distance;
- (void)moveCamera;
@end

@implementation VGGameModel

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithSize:(CGSize)size {
    self = [super init];
    if (self) {
        UIView* view = [CCDirector sharedDirector].view;

        UISwipeGestureRecognizer* swipeRecognizer = [[UISwipeGestureRecognizer alloc] init];
        swipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        swipeRecognizer.numberOfTouchesRequired = 1;
        [swipeRecognizer addTarget:self action:@selector(didSwipe:)];
        [view addGestureRecognizer:swipeRecognizer];
        
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] init];
        tapRecognizer.numberOfTouchesRequired = 1;
        tapRecognizer.numberOfTapsRequired = 1;
        [tapRecognizer addTarget:self action:@selector(didTap:)];
        [view addGestureRecognizer:tapRecognizer];
        
        _speed = 300;
        _ground = [[VGGroundModel alloc] init];
        _ground.delegate = self;
        _character = [[VGCharacterModel alloc] init];
    }
    return self;
}


- (void)update:(CCTime)dt {
    [self.ground update:dt travelledXDistance:self.travelledXDistance];
    [self moveCharacter:self.speed * dt];
    [self moveCamera];
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (CGFloat)travelledXDistance {
    return self.character.position.x - VG_CHARACTER_INIT_POSITION.x;
}

- (void)moveCharacter:(CGFloat)distance {
    CCTime dt = distance / self.speed;
    
    if (self.character.isJumping) {
        CGPoint oldPosition = self.character.position;
        CGPoint newPosition = CGPointMake(self.character.position.x + self.character.velocity.x * dt,
                                         self.character.position.y + self.character.velocity.y * dt);
        
        //Check for curve intersection
        NSDictionary* dic;
        if (newPosition.y < oldPosition.y)
            dic = [self.ground pointInfoBetweenOldPosition:oldPosition newPosition:newPosition];
        
        if (dic && ((NSNumber*)dic[@"positionFound"]).boolValue) {
            self.character.position = ((NSValue*)dic[@"position"]).CGPointValue;
            self.character.angle = ((NSNumber*)dic[@"angle"]).floatValue;
            self.character.velocity = CGPointMake(self.speed * cosf(self.character.angle), self.speed * sinf(self.character.angle));
            self.character.jumping = NO;
        } else {
            self.character.position = newPosition;
            self.character.velocity = CGPointMake(self.character.velocity.x, self.character.velocity.y + dt * VG_GRAVITY);
        }
    } else {
        NSDictionary* dic = [self.ground nextPositionInfo:distance];
        if (((NSNumber*)dic[@"positionFound"]).boolValue) {
            //On curve
            self.character.position = ((NSValue*)dic[@"position"]).CGPointValue;
            self.character.angle = ((NSNumber*)dic[@"angle"]).floatValue;
            self.character.velocity = CGPointMake(distance * cosf(self.character.angle) / dt, distance * sinf(self.character.angle) / dt);
        } else {
            self.character.jumping = YES;
            self.character.position = ((NSValue*)dic[@"position"]).CGPointValue;
            [self moveCharacter:((NSNumber*)dic[@"remainingDistance"]).floatValue];
            return;
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(characterDidMove:angle:)]) {
        [self.delegate characterDidMove:self.character.position angle:self.character.angle];
    }
}

- (void)moveCamera {
    NSDictionary* positionInfo = [self.ground cameraPositionInfoForX:self.character.position.x];
    if (positionInfo) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraDidMoveAtPosition:scale:)]) {
            CGPoint point = ((NSValue*)positionInfo[@"position"]).CGPointValue;
            CGFloat scale = ((NSNumber*)positionInfo[@"scale"]).floatValue;
            [self.delegate cameraDidMoveAtPosition:point scale:scale];
        }

    }
}

/////////////////////////////////////////////////
#pragma mark - VGGroundModelDelegate delegate
/////////////////////////////////////////////////

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

/////////////////////////////////////////////////
#pragma mark - Touch delegate
/////////////////////////////////////////////////

- (void)didTap:(UITapGestureRecognizer*)recognizer {
    if (!self.character.isJumping && [self.ground canJump]) {
        self.character.velocity = CGPointMake(self.character.velocity.x, self.character.velocity.y + VG_CHARACTER_JUMP_VELOCITY.y);
        self.character.jumping = YES;
    }
}

- (void)didSwipe:(UISwipeGestureRecognizer*)recognizer {
    [self.ground enterLooping];
}

@end
