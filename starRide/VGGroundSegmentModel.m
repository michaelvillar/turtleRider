//
//  VGGroundSegmentModel.m
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundSegmentModel.h"
#import "VGConstant.h"

@interface VGGroundSegmentModel ()
@property (strong, readonly) NSMutableArray* guideArcLengths;
@property (assign, readwrite) CGFloat currentArcLength;

- (void)loadGuidePoints:(NSDictionary*)data;
- (CGFloat)tFromX:(CGFloat)x;
- (CGFloat)ratioFromT:(CGFloat)t;
@end

@implementation VGGroundSegmentModel

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _guideArcLengths = [[NSMutableArray alloc] init];
        _totalArcLength = ((NSNumber*)data[@"arc_length"]).floatValue;
        _currentArcLength = 0;
        _bezierPoints = malloc(3 * sizeof(CGPoint));
        
        NSDictionary* bezierPoints = data[@"bezier_points"];
        _bezierPoints[0] = CGPointMake(((NSNumber*)bezierPoints[@"start"][@"x"]).floatValue,
                                       -((NSNumber*)bezierPoints[@"start"][@"y"]).floatValue);
        _bezierPoints[1] = CGPointMake(((NSNumber*)bezierPoints[@"control"][@"x"]).floatValue,
                                       -((NSNumber*)bezierPoints[@"control"][@"y"]).floatValue);
        _bezierPoints[2] = CGPointMake(((NSNumber*)bezierPoints[@"end"][@"x"]).floatValue,
                                       -((NSNumber*)bezierPoints[@"end"][@"y"]).floatValue);
        
        _extremityPoints = malloc(2 * sizeof(CGPoint));
        _extremityPoints[0] = _bezierPoints[0];
        _extremityPoints[1] = _bezierPoints[2];
        
        [self loadGuidePoints:data];
    }
    return self;
}

- (NSDictionary*)nextPositionInfo:(CGFloat)distance {
    CGFloat newLength = self.currentArcLength + distance;
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    if (newLength > self.totalArcLength) {
        self.currentArcLength = self.totalArcLength;
        dic[@"positionFound"] = @(false);
        dic[@"position"] = [NSValue valueWithCGPoint:self.extremityPoints[1]];
        dic[@"distanceRemaining"] = @(newLength - self.totalArcLength);
        dic[@"angle"] = @(atanf([self slopeFromT:1]));
        return dic;
    } else {
        self.currentArcLength = newLength;
        CGFloat t = [self tFromRatio:self.currentArcLength / self.totalArcLength];
        dic[@"positionFound"] = @(true);
        dic[@"position"] = [NSValue valueWithCGPoint:[self pointFromT:t]];
        dic[@"angle"] = @(atanf([self slopeFromT:t]));
    }
    return dic;
}

- (NSDictionary*)pointInfoBetweenOldPosition:(CGPoint)oldPosition newPosition:(CGPoint)newPosition {
    CGFloat x = oldPosition.x + (newPosition.x - oldPosition.x) / 2;
    if (x < self.extremityPoints[0].x)
        x = self.extremityPoints[0].x;
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    CGFloat t = [self tFromX:x];
    CGPoint point = [self pointFromT:t];
    
    if ((oldPosition.y >= newPosition.y &&
         point.y <= oldPosition.y + VG_CURVE_INTERSECTION_SECURITY_OFFSET &&
         point.y >= newPosition.y - VG_CURVE_INTERSECTION_SECURITY_OFFSET) ||
        (oldPosition.y <= newPosition.y &&
         point.y <= newPosition.y + VG_CURVE_INTERSECTION_SECURITY_OFFSET &&
         point.y >= oldPosition.y - VG_CURVE_INTERSECTION_SECURITY_OFFSET)) {
        dic[@"position"] = [NSValue valueWithCGPoint:point];
        dic[@"positionFound"] = @(true);
        self.currentArcLength = [self ratioFromT:t] * self.totalArcLength;
    } else {
        dic[@"positionFound"] = @(false);
    }
    
    return dic;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)loadGuidePoints:(NSDictionary*)data {
    //Normal curve
    if (((NSNumber*)data[@"type"]).intValue < 2) {
        CGPoint lastPoint = self.bezierPoints[0];
        CGFloat totalLength = 0;
        int count = round(_totalArcLength / VG_GROUND_SEGMENT_SIZE);

        for (int i = 0; i < count; i++) {
            CGFloat t = (CGFloat)i / (CGFloat)(count - 1);
            CGPoint point = [self pointFromT:t];
            CGFloat dl = sqrtf(powf(point.x - lastPoint.x, 2) + powf(point.y - lastPoint.y, 2));
            totalLength += dl;
            [self.guideArcLengths addObject:[NSNumber numberWithFloat:totalLength]];
            lastPoint = point;
        }
    }
    
    //Looping
}

- (CGFloat)tFromX:(CGFloat)x {
    CGFloat x1 = self.bezierPoints[0].x;
    CGFloat x2 = self.bezierPoints[1].x;
    CGFloat x3 = self.bezierPoints[2].x;
    
    CGFloat a = x1 - 2 * x2 + x3;
    CGFloat b = - 2 * x1 + 2 * x2;
    CGFloat c = x1 - x;
    
    CGFloat t1;
    CGFloat t2;
    
    if (a == 0) {
        t1 = -c / b;
        t2 = 0;
    } else {
        CGFloat rho = b * b - 4 * a * c;
        t1 = (- b + sqrtf(rho)) / (2 * a);
        t2 = (- b - sqrtf(rho)) / (2 * a);
    }
    
    if (t1 >= 0 && t1 <= 1) {
        return t1;
    }
    else if (t2 >= 0 && t2 <= 1) {
        return t2;
    }
    
    [[NSException exceptionWithName:@"Segment Exception" reason:@"Invalid T from X" userInfo:nil] raise];
    return 0;
}

- (CGPoint)pointFromT:(CGFloat)t {
    CGFloat x = (1 - t) * (1 - t) * self.bezierPoints[0].x + 2 * (1 - t) * t * self.bezierPoints[1].x + t * t * self.bezierPoints[2].x;
    CGFloat y = (1 - t) * (1 - t) * self.bezierPoints[0].y + 2 * (1 - t) * t * self.bezierPoints[1].y + t * t * self.bezierPoints[2].y;
    return CGPointMake(x, y);
}

- (CGFloat)slopeFromT:(CGFloat)t {
    CGFloat x = 2 * (1 - t) * (self.bezierPoints[1].x - self.bezierPoints[0].x) + 2 * t * (self.bezierPoints[2].x - self.bezierPoints[1].x);
    CGFloat y = 2 * (1 - t) * (self.bezierPoints[1].y - self.bezierPoints[0].y) + 2 * t * (self.bezierPoints[2].y - self.bezierPoints[1].y);
    if (x == 0) {
        if (y >= 0)
            return INFINITY;
        else
            return -INFINITY;
    }
    return y / x;
}

- (CGFloat)ratioFromT:(CGFloat)t {
    CGFloat tInc = (1.0 / self.guideArcLengths.count);
    int index = floor(t / tInc);
    CGFloat arcLength = ((NSNumber*)self.guideArcLengths[index]).floatValue;
    if (index == self.guideArcLengths.count - 1) {
        return arcLength / self.totalArcLength;
    } else {
        CGFloat nextArcLength = ((NSNumber*)self.guideArcLengths[index + 1]).floatValue;
        CGFloat arcLengthDiff = nextArcLength - arcLength;
        CGFloat tRatio = (t - tInc * index) / tInc;
        return (arcLength + arcLengthDiff * tRatio) / self.totalArcLength;
    }
}

- (CGFloat)tFromRatio:(CGFloat)ratio {
    CGFloat targetLength = ratio * self.totalArcLength;
    int low = 0;
    int high = (int)self.guideArcLengths.count - 1;
    int index = 0;
    while (low < high) {
        index = low + floor((high - low) / 2);
        if (((NSNumber*)self.guideArcLengths[index]).floatValue < targetLength) {
            low = index + 1;
        } else {
            high = index;
        }
    }
    
    if (((NSNumber*)self.guideArcLengths[index]).floatValue > targetLength) {
        index--;
    }
    
    CGFloat beforeLength = ((NSNumber*)self.guideArcLengths[index]).floatValue;
    CGFloat t;
    if (beforeLength == targetLength) {
        t = index / (self.guideArcLengths.count - 1);
    } else {
        t = (index + (targetLength - beforeLength) / (((NSNumber*)self.guideArcLengths[index + 1]).floatValue - beforeLength)) / (self.guideArcLengths.count - 1);
    }
    return t;
}

@end
