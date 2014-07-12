//
//  VGGroundLoopingSegmentModel.m
//  starRide
//
//  Created by Sebastien Villar on 12/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundLoopingSegmentModel.h"
#import "VGGroundNormalSegmentModel.h"

@interface VGGroundLoopingSegmentModel ()
@property (strong, readonly) VGGroundNormalSegmentModel* originalSegment;
@property (assign, readonly) CGPoint loopingStart;
@end

@implementation VGGroundLoopingSegmentModel
@synthesize extremityPoints = _extremityPoints;

- (id)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _originalSegment = [[VGGroundNormalSegmentModel alloc] initWithData:data[@"original_segment"]];
        _bezierPoints = _originalSegment.bezierPoints;
        _totalArcLength = _originalSegment.totalArcLength;
        _extremityPoints = _originalSegment.extremityPoints;
        NSDictionary* loopingCenterData = data[@"looping_center"];
        _loopingCenter = CGPointMake(((NSNumber*)loopingCenterData[@"x"]).floatValue, -((NSNumber*)loopingCenterData[@"y"]).floatValue);
        NSDictionary* loopingStartData = data[@"looping_start"];
        _loopingStart = CGPointMake(((NSNumber*)loopingStartData[@"x"]).floatValue, -((NSNumber*)loopingStartData[@"y"]).floatValue);
        _loopingRadius = ((NSNumber*)data[@"looping_radius"]).floatValue;
    }
    return self;
}

- (NSDictionary*)nextPositionInfo:(CGFloat)distance {
    return [self.originalSegment nextPositionInfo:distance];
}

- (NSDictionary*)pointInfoBetweenOldPosition:(CGPoint)oldPosition newPosition:(CGPoint)newPosition {
    return [self.originalSegment pointInfoBetweenOldPosition:oldPosition newPosition:newPosition];
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (CGPoint)pointFromT:(CGFloat)t {
    return [self.originalSegment pointFromT:t];
}

- (CGFloat)tFromRatio:(CGFloat)ratio {
    return [self.originalSegment tFromRatio:ratio];
}
@end
