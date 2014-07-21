//
//  VGGroundLoopingSegmentModel.m
//  starRide
//
//  Created by Sebastien Villar on 12/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundLoopingSegmentModel.h"
#import "VGGroundNormalSegmentModel.h"
#import "VGBezierModel.h"
#import "VGConstant.h"

@interface VGGroundLoopingSegmentModel ()
@property (assign, readwrite) CGFloat currentCircleAngle;
@property (assign, readwrite, getter = isLoopingEnabled) BOOL loopingEnabled;
@property (assign, readwrite, getter = isInLooping) BOOL inLooping;
@property (assign, readwrite) int currentSegment;

- (CGFloat)daForDistance:(CGFloat)distance;
- (CGFloat)distanceForDa:(CGFloat)da;
@end

@implementation VGGroundLoopingSegmentModel
@synthesize extremityPoints = _extremityPoints;

- (id)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _segments = [[NSMutableArray alloc] init];
        NSArray* beziersArray = data[@"beziers"];
        for (int i = 0; i < beziersArray.count; i++) {
            NSDictionary* bezierPoints = beziersArray[i];
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
            dic[@"type"] = @0;
            dic[@"bezier"] = [[NSMutableDictionary alloc] initWithDictionary:bezierPoints];

            VGGroundNormalSegmentModel* segment = [[VGGroundNormalSegmentModel alloc] initWithData:dic];
            [_segments addObject:segment];
        }
        
        _circleCenter = CGPointMake(((NSNumber*)data[@"circle"][@"center"][@"x"]).floatValue,
                                    -((NSNumber*)data[@"circle"][@"center"][@"y"]).floatValue);
        _circleRadius = ((NSNumber*)data[@"circle"][@"radius"]).floatValue;
        _circleStartAngle = 0;
        _circleEndAngle = 3 * M_PI_2;
        
        VGGroundNormalSegmentModel* segment = _segments[1];
        _loopingEntranceTs = malloc(2 * sizeof(CGFloat));
        _loopingEntranceTs[0] = [segment.bezier tFromRatio:(segment.bezier.arcLength - VG_LOOPING_ENTRANCE_SIZE) / segment.bezier.arcLength];
        _loopingEntranceTs[1] = 1;
        
        _extremityPoints = malloc(2 * sizeof(CGPoint));
        _extremityPoints[0] = ((VGGroundNormalSegmentModel*)_segments[0]).extremityPoints[0];
        _extremityPoints[1] = ((VGGroundNormalSegmentModel*)_segments[2]).extremityPoints[1];
        
        _currentCircleAngle = 0;
        _currentSegment = 0;
    }
    return self;
}

- (NSDictionary*)nextPositionInfo:(CGFloat)distance {
    if (self.isInLooping) {
        self.currentCircleAngle += [self daForDistance:distance];
        if (self.currentCircleAngle >= self.circleEndAngle) {
            CGFloat remainingDistance = [self distanceForDa:self.currentCircleAngle - 3 * M_PI_2];
            self.inLooping = NO;
            self.loopingEnabled = NO;
            self.currentSegment++;
            return [self nextPositionInfo:remainingDistance];
        } else {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
            CGPoint point = CGPointMake(self.circleCenter.x + cosf(self.currentCircleAngle) * self.circleRadius,
                                        self.circleCenter.y + sinf(self.currentCircleAngle) * self.circleRadius);
            dic[@"positionFound"] = @(true);
            dic[@"position"] = [NSValue valueWithCGPoint:point];
            dic[@"angle"] = @(self.currentCircleAngle + M_PI_2);
            return dic;
        }
    } else {
        VGGroundNormalSegmentModel* segment = self.segments[self.currentSegment];
    
        NSDictionary* dic = [segment nextPositionInfo:distance];
        if (!((NSNumber*)dic[@"positionFound"]).boolValue) {
            CGFloat remainingDistance = ((NSNumber*)dic[@"remainingDistance"]).floatValue;
            if (self.currentSegment == 0 && self.isLoopingEnabled) {
                self.currentSegment++;
                return [self nextPositionInfo:remainingDistance];
            }
            
            if (self.currentSegment == 1) {
                self.inLooping = YES;
                return [self nextPositionInfo:remainingDistance];
            }
            
            NSMutableDictionary* newDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
            newDic[@"fall"] = @(true);
            return newDic;
        }
        return dic;
    }
    return nil;
}

- (NSDictionary*)pointInfoBetweenOldPosition:(CGPoint)oldPosition newPosition:(CGPoint)newPosition {
    VGGroundNormalSegmentModel* segment0 = self.segments[0];
    if (newPosition.x >= segment0.extremityPoints[0].x && newPosition.x <= segment0.extremityPoints[1].x) {
        NSDictionary* segment0Info = [self.segments[0] pointInfoBetweenOldPosition:oldPosition newPosition:newPosition];
        if (((NSNumber*)segment0Info[@"positionFound"]).boolValue) {
            self.currentSegment = 0;
            return segment0Info;
        }
    }
    
    VGGroundNormalSegmentModel* segment2 = self.segments[2];
    if (newPosition.x >= segment2.extremityPoints[0].x && newPosition.x <= segment2.extremityPoints[1].x) {
        NSDictionary* segment2Info = [self.segments[2] pointInfoBetweenOldPosition:oldPosition newPosition:newPosition];
        if (((NSNumber*)segment2Info[@"positionFound"]).boolValue) {
            self.currentSegment = 2;
            return segment2Info;
        }
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:@(false), @"positionFound", nil];
}

- (BOOL)canJump {
    return !(self.isInLooping || self.currentSegment == 1) ;
}

- (void)enterLooping {
    if (self.currentSegment != 0)
        return;
    
    VGGroundNormalSegmentModel* segment = self.segments[0];
    CGFloat t = [segment.bezier tFromRatio:segment.currentArcLength / segment.bezier.arcLength];
    if (t >= self.loopingEntranceTs[0] && t <= self.loopingEntranceTs[1]) {
        self.loopingEnabled = YES;
    }
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (CGFloat)daForDistance:(CGFloat)distance {
    return distance / self.circleRadius;
}

- (CGFloat)distanceForDa:(CGFloat)da {
    return da / self.circleRadius;
}

@end
