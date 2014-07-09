//
//  VGGroundSegment.m
//  starRide
//
//  Created by Sebastien Villar on 09/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundSegment.h"
#import "VGConstant.h"

#import "cocos2d.h"

@interface VGGroundSegment ()
@property (strong, readonly) NSDictionary* data;
@property (strong, readonly) NSMutableArray* arcLengths;
@property (assign, readwrite) int arcPointsCount;
@property (assign, readonly) CGFloat totalArcLength;
@property (assign, readwrite) CGPoint* bezierPoints;
@property (assign, readwrite) CGFloat currentArcLength;
@property (assign, readwrite) CGRect contentRect;

- (void)loadGuidePoints;
- (void)drawPoints;
- (CGPoint)pointFromT:(CGFloat)t;
- (CGFloat)tFromRatio:(CGFloat)ratio;

@end

@implementation VGGroundSegment

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithData:(NSDictionary*)data {
    self = [super init];
    if (self) {
        _data = data;
        _arcLengths = [[NSMutableArray alloc] init];
        _currentArcLength = 0;
        _totalArcLength = ((NSNumber*)_data[@"arc_length"]).floatValue;
        _arcPointsCount = _totalArcLength / VG_GROUND_SEGMENT_SIZE;
        _bezierPoints = malloc(3 * sizeof(CGPoint));
        
        NSDictionary* bezierPoints = self.data[@"bezier_points"];
        _bezierPoints[0] = CGPointMake(((NSNumber*)bezierPoints[@"start"][@"x"]).floatValue,
                                           -((NSNumber*)bezierPoints[@"start"][@"y"]).floatValue);
        _bezierPoints[1] = CGPointMake(((NSNumber*)bezierPoints[@"control"][@"x"]).floatValue,
                                           -((NSNumber*)bezierPoints[@"control"][@"y"]).floatValue);
        _bezierPoints[2] = CGPointMake(((NSNumber*)bezierPoints[@"end"][@"x"]).floatValue,
                                           -((NSNumber*)bezierPoints[@"end"][@"y"]).floatValue);
        
        [self loadGuidePoints];
        [self drawPoints];
    }
    return self;
}

- (NSDictionary*)nextPosition:(CGFloat)distance {
    self.currentArcLength += distance;
    CGFloat t = [self tFromRatio:self.currentArcLength / self.totalArcLength];
    NSMutableDictionary* newDic = [[NSMutableDictionary alloc] init];
    if (t > 1) {
        [newDic setObject:[NSNumber numberWithInt:VGkPointOffSegment] forKey:@"positionType"];
        [newDic setObject:[NSNumber numberWithFloat:self.currentArcLength - self.totalArcLength] forKey:@"distanceRemaining"];
    } else {
        [newDic setObject:[NSNumber numberWithInt:VGkPointOnSegment] forKey:@"positionType"];
        [newDic setObject:[NSValue valueWithCGPoint:[self pointFromT:t]] forKey:@"position"];
    }
    return newDic;
}

- (CGFloat)remainingDistance {
    return self.totalArcLength - self.currentArcLength;
}

- (CGPoint)startPoint {
    return self.bezierPoints[0];
}

- (CGPoint)endPoint {
    return self.bezierPoints[2];
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)loadGuidePoints {
    //Normal curve
    if (((NSNumber*)self.data[@"type"]).intValue < 2) {

        CGPoint lastPoint = self.bezierPoints[0];
        CGFloat totalLength = 0;
        
        for (int i = 0; i < self.arcPointsCount; i++) {
            CGFloat t = (CGFloat)i / (CGFloat)(self.arcPointsCount - 1);
            CGPoint point = [self pointFromT:t];
            CGFloat dl = sqrtf(powf(point.x - lastPoint.x, 2) + powf(point.y - lastPoint.y, 2));
            totalLength += dl;
            [self.arcLengths addObject:[NSNumber numberWithFloat:totalLength]];
            lastPoint = point;
        }
    }
    
    //Looping
}

- (void)drawPoints {
    CGPoint lastPoint = self.bezierPoints[0];
    int segmentsCount = self.totalArcLength / VG_GROUND_SEGMENT_SIZE;
    
    for (CGFloat r = 0; r <= 1; r += 1.0 / segmentsCount) {
        CGPoint point = [self pointFromT:[self tFromRatio:r]];
        [self drawDot:point radius:2 color:[CCColor redColor]];
        [self drawSegmentFrom:lastPoint to:point radius:1 color:[CCColor blackColor]];
        lastPoint = point;
    }
    
    [self drawSegmentFrom:lastPoint to:self.bezierPoints[2] radius:1 color:[CCColor blackColor]];
}

- (CGPoint)pointFromT:(CGFloat)t {
    CGFloat x = (1 - t) * (1 - t) * self.bezierPoints[0].x + 2 * (1 - t) * t * self.bezierPoints[1].x + t * t * self.bezierPoints[2].x;
    CGFloat y = (1 - t) * (1 - t) * self.bezierPoints[0].y + 2 * (1 - t) * t * self.bezierPoints[1].y + t * t * self.bezierPoints[2].y;
    return CGPointMake(x, y);
}

- (CGFloat)tFromRatio:(CGFloat)ratio {
    CGFloat targetLength = ratio * ((NSNumber*)self.arcLengths[self.arcPointsCount - 1]).floatValue;
    int low = 0;
    int high = self.arcPointsCount - 1;
    int index = 0;
    
    while (low < high) {
        index = low + floor((high - low) / 2);
        if (((NSNumber*)self.arcLengths[index]).floatValue < targetLength) {
            low = index + 1;
        } else {
            high = index;
        }
    }
    
    if (((NSNumber*)self.arcLengths[index]).floatValue > targetLength) {
        index--;
    }
    
    CGFloat beforeLength = ((NSNumber*)self.arcLengths[index]).floatValue;
    CGFloat t;
    if (beforeLength == targetLength) {
        t = index / (self.arcPointsCount - 1);
    } else {
        t = (index + (targetLength - beforeLength) / (((NSNumber*)self.arcLengths[index + 1]).floatValue - beforeLength)) / (self.arcPointsCount - 1);
    }
    return t;
}


@end
