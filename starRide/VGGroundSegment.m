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
@property (assign, readwrite) CGPoint* bezierPoints;

- (void)loadPoints;

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
        _arcPointsCount = ((NSNumber*)_data[@"arc_length"]).floatValue / VG_GROUND_SEGMENT_SIZE;
        _bezierPoints = malloc(3 * sizeof(CGPoint));
        
        NSDictionary* bezierPoints = self.data[@"bezier_points"];
        _bezierPoints[0] = CGPointMake(((NSNumber*)bezierPoints[@"start"][@"x"]).floatValue,
                                           -((NSNumber*)bezierPoints[@"start"][@"y"]).floatValue);
        _bezierPoints[1] = CGPointMake(((NSNumber*)bezierPoints[@"control"][@"x"]).floatValue,
                                           -((NSNumber*)bezierPoints[@"control"][@"y"]).floatValue);
        _bezierPoints[2] = CGPointMake(((NSNumber*)bezierPoints[@"end"][@"x"]).floatValue,
                                           -((NSNumber*)bezierPoints[@"end"][@"y"]).floatValue);
        
        [self loadPoints];
    }
    return self;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)loadPoints {
    //Normal curve
    if (((NSNumber*)self.data[@"type"]).intValue < 2) {

        CGPoint lastPoint = self.bezierPoints[0];
        CGFloat totalLength = 0;;
        
        for (int i = 0; i < self.arcPointsCount; i++) {
            CGFloat t = (CGFloat)i / (CGFloat)(self.arcPointsCount - 1);
            CGPoint point = [self pointFromT:t];
            CGFloat dl = sqrtf(powf(point.x - lastPoint.x, 2) + powf(point.y - lastPoint.y, 2));
            totalLength += dl;
            [self.arcLengths addObject:[NSNumber numberWithFloat:totalLength]];
            lastPoint = point;
        }
        
        lastPoint = self.bezierPoints[0];
        int segmentsCount = ((NSNumber*)_data[@"arc_length"]).floatValue / VG_GROUND_SEGMENT_SIZE;
        for (CGFloat r = 0; r <= 1; r += 1.0 / segmentsCount) {
            CGPoint point = [self pointFromT:[self tFromRatio:r]];
            [self drawDot:point radius:2 color:[CCColor redColor]];
            [self drawSegmentFrom:lastPoint to:point radius:1 color:[CCColor blackColor]];
            lastPoint = point;
        }
        
        [self drawSegmentFrom:lastPoint to:self.bezierPoints[2] radius:1 color:[CCColor blackColor]];
        
    }
    
    //Looping
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
