//
//  VGGroundSegmentModel.h
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    VGkSegmentPositionNotFound,
    VGkSegmentPositionFound
} VGkSegmentPositionResult;

@interface VGGroundSegmentModel : NSObject
@property (assign, readonly) CGPoint* extremityPoints;
@property (assign, readwrite) CGPoint* bezierPoints;
@property (assign, readonly) CGFloat totalArcLength;

- (id)initWithData:(NSDictionary *)data;
- (NSDictionary*)nextPositionInfo:(CGFloat)distance;
- (NSDictionary*)pointInfoBetweenOldPosition:(CGPoint)oldPosition newPosition:(CGPoint)newPosition;
- (CGFloat)tFromRatio:(CGFloat)ratio;
- (CGPoint)pointFromT:(CGFloat)t;
@end
