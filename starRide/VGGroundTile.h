//
//  VGGroundTile.h
//  starRide
//
//  Created by Sebastien Villar on 09/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "CCDrawNode.h"
#import "VGGroundTileModel.h"

@interface VGGroundTile : CCDrawNode
@property (assign, readonly) CGPoint* extremityPoints;

- (id)initWithModel:(VGGroundTileModel*)model;
- (void)drawModel;
@end
