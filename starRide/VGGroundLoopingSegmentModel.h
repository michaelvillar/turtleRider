//
//  VGGroundLoopingSegmentModel.h
//  starRide
//
//  Created by Sebastien Villar on 12/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VGGroundSegmentModelProtocol.h"

@interface VGGroundLoopingSegmentModel : NSObject <VGGroundSegmentModelProtocol>
@property (assign, readwrite) CGPoint* bezierPoints;
@property (assign, readonly) CGFloat totalArcLength;
@property (assign, readonly) CGPoint loopingCenter;
@property (assign, readonly) CGFloat loopingRadius;
@property (assign, readonly) CGFloat* loopingEntranceTs;

- (BOOL)canJump;
- (void)enterLooping;
@end
