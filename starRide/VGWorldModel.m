//
//  VGWorldModel.m
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGWorldModel.h"
#import "VGCharacterModel.h"
#import "VGGroundTileModel.h"
#import "VGGameModel.h"

@interface VGWorldModel ()
@property (strong, readonly) VGCharacterModel* character;
@property (strong, readwrite) NSMutableDictionary* currentPointInfo;

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
        _character = [[VGCharacterModel alloc] init];
        _tiles = [[NSMutableArray alloc] init];
        _currentPointInfo = [[NSMutableDictionary alloc] init];
        
        //Init tiles
        VGGroundTileModel* tile = [VGGroundTileModel tileFromName:@"level1"];
        [self.tiles addObject:tile];
        
        VGGroundTileModel* tile2 = [VGGroundTileModel tileFromName:@"level1"];
        [self.tiles addObject:tile2];
    }
    return self;
}

- (void)update:(CCTime)dt {
    //Modify character position")
    [self moveCharacter:self.game.speed * dt];
}

- (CGPoint)characterPosition {
    if (!self.currentPointInfo)
        return CGPointMake(0, 160);
    
    CGPoint position = ((NSValue*)self.currentPointInfo[@"position"]).CGPointValue;
    CGPoint tileOrigin = ((NSValue*)self.currentPointInfo[@"tileOrigin"]).CGPointValue;
    return CGPointMake(tileOrigin.x + position.x, tileOrigin.y + position.y);
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)moveCharacter:(CGFloat)distance {
    if (!self.currentPointInfo || self.tiles.count == 0)
        return;
    
    if (!self.currentPointInfo[@"tileIndex"])
        self.currentPointInfo[@"tileIndex"] = @0;
    
    if (!self.currentPointInfo[@"tileOrigin"])
        self.currentPointInfo[@"tileOrigin"] = [NSValue valueWithCGPoint:CGPointMake(0, 160)];
    
    int index = ((NSNumber*)self.currentPointInfo[@"tileIndex"]).intValue;
    
    VGGroundTileModel* tile = self.tiles[index];
    self.currentPointInfo = [tile nextPositionInfo:distance info:self.currentPointInfo];
    switch (((NSNumber*)self.currentPointInfo[@"positionResult"]).intValue) {
        case VGKTilePositionNotFound: {
            index++;
            if (index >= self.tiles.count) {
                self.currentPointInfo = nil;
                return;
            }
            CGPoint oldOrigin = ((NSValue*)self.currentPointInfo[@"tileOrigin"]).CGPointValue;
            CGPoint newOrigin = CGPointMake(oldOrigin.x + tile.extremityPoints[1].x, oldOrigin.y + tile.extremityPoints[1].y);
            
            self.currentPointInfo[@"tileOrigin"] = [NSValue valueWithCGPoint:newOrigin];
            self.currentPointInfo[@"tileIndex"] = [NSNumber numberWithInt:index];
            self.currentPointInfo[@"curveIndex"] = @0;
            self.currentPointInfo[@"segmentIndex"] = @0;
            self.currentPointInfo[@"segmentArc"] = @0;
            [self moveCharacter:distance - ((NSNumber*)self.currentPointInfo[@"distanceRemaining"]).floatValue];
            break;
        }
         
        case VGKTilePositionFall: {
            break;
        }
            
        default:
            break;
    }
}

@end
