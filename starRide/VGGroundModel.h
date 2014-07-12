//
//  VGGroundModel.h
//  starRide
//
//  Created by Sebastien Villar on 11/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VGGroundTileModel.h"
#import "cocos2d.h"

@protocol VGGroundModelDelegate <NSObject>
- (void)didCreateGroundTile:(VGGroundTileModel*)tile atPosition:(CGPoint)position;
- (void)didRemoveGroundTile:(VGGroundTileModel*)tile;
@end

@interface VGGroundModel : NSObject
@property (weak, readwrite) id delegate;

- (void)update:(CCTime)dt travelledXDistance:(CGFloat)distance;
- (NSDictionary*)nextPositionInfo:(CGFloat)distance;
- (NSDictionary*)pointInfoBetweenOldPosition:(CGPoint)oldPosition newPosition:(CGPoint)newPosition;
- (BOOL)canJump;
@end
