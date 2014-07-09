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

- (void)generateGround;
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

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)generateGround {
    if (self.tiles.count == 0) {
        VGGroundTile* tile = [VGGroundTile tileFromName:@"level1"];
        tile.position = CGPointMake(0, 160);
        [self addChild:tile z:0];
        [self.tiles addObject:tile];
    }
}

////////////////////////////////
#pragma mark - Cocos2D
////////////////////////////////


- (void)update:(CCTime)dt {
    [self generateGround];
}

@end
