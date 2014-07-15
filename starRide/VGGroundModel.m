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
            return [self nextPositionInfo:((NSNumber*)dic[@"remainingDistance"]).floatValue];
        }
    } else {
        newDic[@"positionFound"] = @(false);
        newDic[@"position"] = [NSValue valueWithCGPoint:CGPointMake(tile.position.x + position.x, tile.position.y + position.y)];
        newDic[@"remainingDistance"] = dic[@"remainingDistance"];
        newDic[@"angle"] = dic[@"angle"];
        return newDic;
    }
    
    return nil;
}

- (NSDictionary*)pointInfoBetweenOldPosition:(CGPoint)oldPosition newPosition:(CGPoint)newPosition {
    VGGroundTileModel* tile;
    VGGroundTileModel* currentTile;
    int i;
    for (i = 0; i < self.tiles.count; i++) {
        currentTile = self.tiles[i];
        if (newPosition.x >= currentTile.position.x + currentTile.extremityPoints[0].x && newPosition.x <= currentTile.position.x + currentTile.extremityPoints[1].x) {
            tile = currentTile;
            oldPosition = CGPointMake(oldPosition.x - tile.position.x, oldPosition.y - tile.position.y);
            newPosition = CGPointMake(newPosition.x - tile.position.x, newPosition.y - tile.position.y);
            break;
        }
    }
    
    if (!tile)
        return [[NSDictionary alloc] initWithObjectsAndKeys:@"positionFound", @(false), nil];
    
    NSDictionary* dic = [tile pointInfoBetweenOldPosition:oldPosition newPosition:newPosition];
    if (((NSNumber*)dic[@"positionFound"]).boolValue) {
        NSMutableDictionary* newDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
        self.currentTileIndex = i;
        CGPoint position = ((NSValue*)dic[@"position"]).CGPointValue;
        position = CGPointMake(position.x + tile.position.x, position.y + tile.position.y);
        newDic[@"position"] = [NSValue valueWithCGPoint:position];
        return newDic;
    } else
        return dic;
    
    return nil;
}

- (BOOL)canJump {
    return [self.tiles[self.currentTileIndex] canJump];
}

- (void)enterLooping {
    [self.tiles[self.currentTileIndex] enterLooping];
}

- (NSValue*)cameraPositionForX:(CGFloat)x {
    for (int i = 0; i < self.tiles.count; i++) {
        VGGroundTileModel* tile = self.tiles[i];
        if (x >= tile.extremityPoints[0].x + tile.position.x && x <= tile.extremityPoints[1].x + tile.position.x) {
            NSValue* position = [tile cameraPositionForX:x - tile.position.x];
            if (position) {
                CGPoint point = position.CGPointValue;
                point = CGPointMake(point.x + tile.position.x, point.y + tile.position.y);
                return [NSValue valueWithCGPoint:point];
            }
        }
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
