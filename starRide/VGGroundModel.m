//
//  VGGroundModel.m
//  starRide
//
//  Created by Sebastien Villar on 11/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundModel.h"
#import "VGGroundTileModel.h"
#import "VGConstant.h"

@interface VGGroundModel ()
@property (strong, readonly) NSMutableArray* tiles;
@property (assign, readwrite) int currentTileIndex;
@end

@implementation VGGroundModel

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)init {
    self = [super init];
    if (self) {
        _tiles = [[NSMutableArray alloc] init];
        _currentTileIndex = 0;
    }
    return self;
}

- (void)update:(CCTime)dt travelledXDistance:(CGFloat)distance {
    //Remove tiles
    if (self.tiles.count > 0) {
        VGGroundTileModel* firstTile = self.tiles.firstObject;
        if (firstTile.position.x + firstTile.extremityPoints[1].x - distance < - VG_GROUND_SECURITY_OFFSET) {
            [self removeTileAtIndex:0];
        }
    }
     
    //Create tiles
    if (self.tiles.count > 0) {
        VGGroundTileModel* lastTile = self.tiles.lastObject;
        if (lastTile.position.x + lastTile.extremityPoints[1].x - distance < [UIScreen mainScreen].applicationFrame.size.height + VG_GROUND_SECURITY_OFFSET) {
            [self createTile];
        }
    } else {
        [self createTile];
    }
}

- (NSDictionary*)nextPositionInfo:(CGFloat)distance {
    if (self.tiles.count == 0)
        return nil;
    
    VGGroundTileModel* tile = self.tiles[self.currentTileIndex];
    NSDictionary* dic = [tile nextPositionInfo:distance];
    NSMutableDictionary* newDic = [[NSMutableDictionary alloc] init];
    CGPoint position = ((NSValue*)dic[@"position"]).CGPointValue;
    
    if (((NSNumber*)dic[@"positionFound"]).boolValue) {
        newDic[@"positionFound"] = @(true);
        newDic[@"position"] = [NSValue valueWithCGPoint:CGPointMake(tile.position.x + position.x, tile.position.y + position.y)];
        newDic[@"angle"] = dic[@"angle"];
        return newDic;
    } else if (CGPointEqualToPoint(position, tile.extremityPoints[1])) {
        if (self.currentTileIndex + 1 < self.tiles.count) {
            self.currentTileIndex++;
            return [self nextPositionInfo:((NSNumber*)dic[@"distanceRemaining"]).floatValue];
        }
    } else {
        newDic[@"positionFound"] = @(false);
        newDic[@"position"] = [NSValue valueWithCGPoint:CGPointMake(tile.position.x + position.x, tile.position.y + position.y)];
        newDic[@"distanceRemaining"] = dic[@"distanceRemaining"];
        newDic[@"angle"] = dic[@"angle"];
        return newDic;
    }
    
    return nil;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)createTile {
    VGGroundTileModel* tile = [VGGroundTileModel tileFromName:@"level1"];
    if (self.tiles.count <= 0) {
        tile.position = CGPointMake(0, VG_CHARACTER_INIT_POSITION.y);
    } else {
        VGGroundTileModel* lastTile = self.tiles.lastObject;
        tile.position = CGPointMake(lastTile.position.x + lastTile.extremityPoints[1].x, lastTile.position.y + lastTile.extremityPoints[1].y);
    }
    [self.tiles addObject:tile];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRemoveGroundTile:)]) {
        [self.delegate didCreateGroundTile:tile atPosition:tile.position];
    }
}

- (void)removeTileAtIndex:(int)index {
    VGGroundTileModel* currentTile = self.tiles[index];
    [self.tiles removeObjectAtIndex:index];
    self.currentTileIndex--;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRemoveGroundTile:)]) {
        [self.delegate didRemoveGroundTile:currentTile];
    }
}

@end
