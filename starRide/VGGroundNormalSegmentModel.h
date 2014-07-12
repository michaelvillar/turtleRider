//
//  VGGroundSegmentModel.h
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VGGroundSegmentModelProtocol.h"

typedef enum {
    VGkSegmentPositionNotFound,
    VGkSegmentPositionFound
} VGkSegmentPositionResult;

@interface VGGroundNormalSegmentModel : NSObject <VGGroundSegmentModelProtocol>
@property (assign, readwrite) CGPoint* bezierPoints;
@property (assign, readonly) CGFloat totalArcLength;
@property (assign, readwrite) CGFloat currentArcLength;

- (CGFloat)ratioFromT:(CGFloat)t;
- (CGFloat)tFromX:(CGFloat)x;
- (BOOL)canJump;
@end
