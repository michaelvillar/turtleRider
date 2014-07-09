//
//  VGGround.m
//  starRide
//
//  Created by Sebastien Villar on 08/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGround.h"
#import "VGGroundTile.h"

@interface VGGround ()
@property (strong, readonly) NSMutableArray* tiles;
@property (strong, readwrite) VGGroundTile* currentTile;

- (void)generateGround;
- (NSValue*)pointValueToGlobal:(NSValue*)value;
@end

@implementation VGGround

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)init {
    self = [super init];
    if (self) {
        _tiles = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSValue*)nextPosition:(CGFloat)distance {
    if (self.currentTile) {
        NSValue* value = [self.currentTile nextPosition:distance];
        if (value) {
            return [self pointValueToGlobal:value];
        } else {
            long index = [self.tiles indexOfObject:self.currentTile] + 1;
            if (index >= self.tiles.count)
                return nil;
            
            VGGroundTile* nextTile = self.tiles[index];
            value = [nextTile nextPosition:distance];
            if (value) {
                self.currentTile = nextTile;
                return [self pointValueToGlobal:value];
            }
        }
    }
    return nil;
}

- (NSValue*)pointValueToGlobal:(NSValue*)value {
    if (!self.currentTile)
        return value;
    
    CGPoint point = value.CGPointValue;
    CGPoint newPoint = CGPointMake(self.position.x + self.currentTile.position.x + point.x,
                                   self.position.y + self.currentTile.position.y + point.y);
    return [NSValue valueWithCGPoint:newPoint];
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)generateGround {
    if (self.tiles.count == 0) {
        VGGroundTile* tile = [VGGroundTile tileFromName:@"level1"];
        self.currentTile = tile;
        tile.position = CGPointMake(0, 160);
        [self addChild:tile z:0];
        [self.tiles addObject:tile];
        
        VGGroundTile* tile2 = [VGGroundTile tileFromName:@"level1"];
        tile2.position = CGPointMake(tile.position.x + tile.endPoint.x, tile.position.y + tile.endPoint.y);
        [self addChild:tile2 z:0];
        [self.tiles addObject:tile2];
    }
}

////////////////////////////////
#pragma mark - Cocos2D
////////////////////////////////


- (void)update:(CCTime)dt {
    [self generateGround];
}

@end
