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
@property (assign, readwrite) CGFloat startAngle;
@property (assign, readwrite) CGFloat currentAngle;
@property (assign, readonly) CGPoint loopingStart;
@property (assign, readwrite, getter = isInLooping) BOOL inLooping;

- (CGFloat)daForDistance:(CGFloat)distance;
- (CGFloat)distanceForDa:(CGFloat)da;
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
        CGFloat tan = (_loopingCenter.y - _loopingStart.y) / (_loopingCenter.x - _loopingStart.x);
        if (tan > 0)
            _startAngle =  atanf(tan) + M_PI;
        else
            _startAngle = atanf(tan) + 2 * M_PI;
        _currentAngle = _startAngle;
        _inLooping = NO;
    }
    return self;
}

- (NSDictionary*)nextPositionInfo:(CGFloat)distance {
    if (self.isInLooping) {
        self.currentAngle += [self daForDistance:distance];
        if (self.currentAngle >= self.startAngle + 2 * M_PI) {
            CGFloat remainingDistance = [self distanceForDa:self.startAngle + 2 * M_PI - self.currentAngle];
            self.inLooping = NO;
            return [self nextPositionInfo:remainingDistance];
        } else {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
            CGPoint point = CGPointMake(self.loopingCenter.x + cosf(self.currentAngle) * self.loopingRadius,
                                        self.loopingCenter.y + sinf(self.currentAngle) * self.loopingRadius);
            dic[@"positionFound"] = @(true);
            dic[@"position"] = [NSValue valueWithCGPoint:point];
            dic[@"angle"] = @(fmod((self.currentAngle + M_PI_2), (2 * M_PI)));
            return dic;
        }
    } else {
        CGFloat currentT = [self.originalSegment tFromRatio:self.originalSegment.currentArcLength / self.originalSegment.totalArcLength];
        CGPoint currentPoint = [self.originalSegment pointFromT:currentT];
        
        NSDictionary* dic = [self.originalSegment nextPositionInfo:distance];
        if (!((NSNumber*)dic[@"positionFound"]).boolValue)
            return dic;
        
        CGPoint nextPoint = ((NSValue*)dic[@"position"]).CGPointValue;
        
        if (currentPoint.x < self.loopingStart.x && nextPoint.x >= self.loopingStart.x) {
            CGFloat startT = [self.originalSegment tFromX:self.loopingStart.x];
            CGFloat startRatio = [self.originalSegment ratioFromT:startT];
            CGFloat startArcLength = self.originalSegment.totalArcLength * startRatio;
            CGFloat remainingDistance = self.originalSegment.currentArcLength - startArcLength;
            self.originalSegment.currentArcLength = startArcLength;
            self.inLooping = YES;
            return [self nextPositionInfo:remainingDistance];
        } else {
            return dic;
        }
    }
}

- (NSDictionary*)pointInfoBetweenOldPosition:(CGPoint)oldPosition newPosition:(CGPoint)newPosition {
    return [self.originalSegment pointInfoBetweenOldPosition:oldPosition newPosition:newPosition];
}

- (BOOL)canJump {
    return !self.isInLooping;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (CGFloat)daForDistance:(CGFloat)distance {
    return distance / self.loopingRadius;
}

- (CGFloat)distanceForDa:(CGFloat)da {
    return da / self.loopingRadius;
}

- (CGPoint)pointFromT:(CGFloat)t {
    return [self.originalSegment pointFromT:t];
}

- (CGFloat)tFromRatio:(CGFloat)ratio {
    return [self.originalSegment tFromRatio:ratio];
}
@end
