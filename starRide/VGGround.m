//
//  VGGround.m
//  starRide
//
//  Created by Sebastien Villar on 08/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGround.h"
#import "VGGroundTile.h"
#import "VGConstant.h"

@interface VGGround ()
@property (strong, readonly) VGWorldModel* world;
@property (strong, readonly) NSMutableArray* tiles;

//- (NSValue*)pointValueToGlobal:(NSValue*)value;
@end

@implementation VGGround

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithWorld:(VGWorldModel*)world {
    self = [super init];
    if (self) {
        _world = world;
        _tiles = [[NSMutableArray alloc] init];
        
        VGGroundTile* lastTile = nil;
        for (VGGroundTileModel* tileModel in _world.tiles) {
            VGGroundTile* tile = [[VGGroundTile alloc] initWithModel:tileModel];
            if (!lastTile) {
                tile.position = CGPointMake(0, 160);
            } else {
                tile.position = CGPointMake(lastTile.position.x + lastTile.extremityPoints[1].x, lastTile.position.y + lastTile.extremityPoints[1].y);
            }
            lastTile = tile;
            [_tiles addObject:tile];
            [self addChild:tile z:0];
        }
        
        for (VGGroundTile* tile in _tiles) {
            [tile drawModel];
        }
    }
    return self;
}



//- (NSValue*)pointValueToGlobal:(NSValue*)value {
//    if (!self.currentTile)
//        return value;
//    
//    CGPoint point = value.CGPointValue;
//    CGPoint newPoint = CGPointMake(self.position.x + self.currentTile.position.x + point.x,
//                                   self.position.y + self.currentTile.position.y + point.y);
//    return [NSValue valueWithCGPoint:newPoint];
//}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

////////////////////////////////
#pragma mark - Cocos2D
////////////////////////////////


- (void)update:(CCTime)dt {
    
}

@end
