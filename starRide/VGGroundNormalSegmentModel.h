//
//  VGGroundSegmentModel.h
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VGGroundSegmentModelProtocol.h"
#import "VGBezierModel.h"

@interface VGGroundNormalSegmentModel : NSObject <VGGroundSegmentModelProtocol>
@property (strong, readonly) VGBezierModel* bezier;
@property (assign, readonly) CGFloat currentArcLength;

- (BOOL)canJump;
@end
