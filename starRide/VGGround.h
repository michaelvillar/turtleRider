//
//  VGGround.h
//  starRide
//
//  Created by Sebastien Villar on 08/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "CCNode.h"
#import "VGGroundTileModel.h"

@interface VGGround : CCNode
- (void)removeTile:(VGGroundTileModel*)tile;
- (void)createTile:(VGGroundTileModel*)tile atPosition:(CGPoint)position;
@end
