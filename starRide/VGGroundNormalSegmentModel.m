//
//  VGGroundSegmentModel.m
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundNormalSegmentModel.h"
#import "VGBezierModel.h"
#import "VGConstant.h"

@interface VGGroundNormalSegmentModel ()
@property (assign, readwrite) CGFloat currentArcLength;
@end

@implementation VGGroundNormalSegmentModel
@synthesize extremityPoints = _extremityPoints;

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        CGPoint start = CGPointMake(((NSNumber*)data[@"bezier"][@"start"][@"x"]).floatValue,
                                       -((NSNumber*)data[@"bezier"][@"start"][@"y"]).floatValue);
        CGPoint control = CGPointMake(((NSNumber*)data[@"bezier"][@"control"][@"x"]).floatValue,
                                       -((NSNumber*)data[@"bezier"][@"control"][@"y"]).floatValue);
        CGPoint end = CGPointMake(((NSNumber*)data[@"bezier"][@"end"][@"x"]).floatValue,
                                       -((NSNumber*)data[@"bezier"][@"end"][@"y"]).floatValue);
        CGFloat arcLength = ((NSNumber*)data[@"bezier"][@"arc_length"]).floatValue;
        
        _bezier = [[VGBezierModel alloc] initWithStart:start control:control end:end arcLength:arcLength];
        
        _extremityPoints = malloc(2 * sizeof(CGPoint));
        _extremityPoints[0] = _bezier.start;
        _extremityPoints[1] = _bezier.end;
    }
    return self;
}

- (NSDictionary*)nextPositionInfo:(CGFloat)distance {
    CGFloat newLength = self.currentArcLength + distance;
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    if (newLength > self.bezier.arcLength) {
        self.currentArcLength = self.bezier.arcLength;
        dic[@"positionFound"] = @(false);
        dic[@"position"] = [NSValue valueWithCGPoint:self.extremityPoints[1]];
        dic[@"remainingDistance"] = @(newLength - self.bezier.arcLength);
        dic[@"angle"] = @(atanf([self.bezier slopeFromT:1]));
        return dic;
    } else {
        self.currentArcLength = newLength;
        CGFloat t = [self.bezier tFromRatio:self.currentArcLength / self.bezier.arcLength];
        dic[@"positionFound"] = @(true);
        dic[@"position"] = [NSValue valueWithCGPoint:[self.bezier pointFromT:t]];
        dic[@"angle"] = @(atanf([self.bezier slopeFromT:t]));
    }
    return dic;
}

- (NSDictionary*)pointInfoBetweenOldPosition:(CGPoint)oldPosition newPosition:(CGPoint)newPosition {
    CGFloat x = oldPosition.x + (newPosition.x - oldPosition.x) / 2;
    if (x < self.extremityPoints[0].x)
        x = self.extremityPoints[0].x;
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    CGFloat t = [self.bezier tFromX:x];
    CGPoint point = [self.bezier pointFromT:t];
    
    if ((oldPosition.y >= newPosition.y &&
         point.y <= oldPosition.y + VG_CURVE_INTERSECTION_SECURITY_OFFSET &&
         point.y >= newPosition.y - VG_CURVE_INTERSECTION_SECURITY_OFFSET) ||
        (oldPosition.y <= newPosition.y &&
         point.y <= newPosition.y + VG_CURVE_INTERSECTION_SECURITY_OFFSET &&
         point.y >= oldPosition.y - VG_CURVE_INTERSECTION_SECURITY_OFFSET)) {
        dic[@"position"] = [NSValue valueWithCGPoint:point];
        dic[@"positionFound"] = @(true);
        self.currentArcLength = [self.bezier ratioFromT:t] * self.bezier.arcLength;
    } else {
        dic[@"positionFound"] = @(false);
    }
    
    return dic;
}

- (BOOL)canJump {
    return true;
}

@end
