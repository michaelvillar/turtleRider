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
