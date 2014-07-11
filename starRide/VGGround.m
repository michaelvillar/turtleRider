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
@property (strong, readonly) NSMutableArray* tileModels;
@property (strong, readonly) NSMutableArray* tiles;
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

- (void)removeTile:(VGGroundTileModel *)tileModel {
    long index = [self.tileModels indexOfObject:tileModel];
    VGGroundTile* tile = [self.tiles objectAtIndex:index];
    [tile removeFromParent];
    
    [self.tileModels removeObjectAtIndex:index];
    [self.tiles removeObjectAtIndex:index];
}

- (void)createTile:(VGGroundTileModel *)tileModel atPosition:(CGPoint)position {
    VGGroundTile* tile = [[VGGroundTile alloc] initWithModel:tileModel];
    [tile drawModel];
    
    [self.tileModels addObject:tileModel];
    [self.tiles addObject:tile];
    
    tile.position = position;
    [self addChild:tile z:0];
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

////////////////////////////////
#pragma mark - Cocos2D
////////////////////////////////


@end
