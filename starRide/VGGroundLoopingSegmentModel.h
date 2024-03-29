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
@property (strong, readonly) NSMutableArray* segments;
@property (assign, readonly) int currentSegment;
@property (assign, readonly) CGFloat* loopingEntranceTs;
@property (assign, readonly) CGPoint circleCenter;
@property (assign, readonly) CGFloat circleRadius;
@property (assign, readonly) CGFloat circleStartAngle;
@property (assign, readonly) CGFloat circleEndAngle;
@property (assign, readonly, getter = isInLooping) BOOL inLooping;
@property (assign, readonly, getter = isLoopingEnabled) BOOL loopingEnabled;


- (BOOL)canJump;
- (void)enterLooping;
@end
