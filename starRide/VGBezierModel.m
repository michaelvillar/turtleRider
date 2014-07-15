//
//  VGBezierModel.m
//  starRide
//
//  Created by Sebastien Villar on 15/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGBezierModel.h"
#import "VGConstant.h"

@interface VGBezierModel ()
@property (strong, readonly) NSMutableArray* guideArcLengths;
@property (assign, readwrite) CGFloat arcLength;

@end

@implementation VGBezierModel

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithStart:(CGPoint)start control:(CGPoint)control end:(CGPoint)end arcLength:(CGFloat)arcLength {
    self = [super init];
    if (self) {
        _start = start;
        _control = control;
        _end = end;
        _guideArcLengths = [[NSMutableArray alloc] init];
        _arcLength = arcLength;
        
        [self loadGuidePoints];
    }
    return self;
}

- (void)loadGuidePoints {
    CGPoint lastPoint = self.start;
    CGFloat totalLength = 0;
    int count = round(_arcLength / VG_GROUND_SEGMENT_SIZE);
    
    for (int i = 0; i < count; i++) {
        CGFloat t = (CGFloat)i / (CGFloat)(count - 1);
        CGPoint point = [self pointFromT:t];
        CGFloat dl = sqrtf(powf(point.x - lastPoint.x, 2) + powf(point.y - lastPoint.y, 2));
        totalLength += dl;
        [self.guideArcLengths addObject:[NSNumber numberWithFloat:totalLength]];
        lastPoint = point;
    }
}

- (CGFloat)tFromX:(CGFloat)x {
    CGFloat x1 = self.start.x;
    CGFloat x2 = self.control.x;
    CGFloat x3 = self.end.x;
    
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
    CGFloat x = (1 - t) * (1 - t) * self.start.x + 2 * (1 - t) * t * self.control.x + t * t * self.end.x;
    CGFloat y = (1 - t) * (1 - t) * self.start.y + 2 * (1 - t) * t * self.control.y + t * t * self.end.y;
    return CGPointMake(x, y);
}

- (CGFloat)slopeFromT:(CGFloat)t {
    CGFloat x = 2 * (1 - t) * (self.control.x - self.start.x) + 2 * t * (self.end.x - self.control.x);
    CGFloat y = 2 * (1 - t) * (self.control.y - self.start.y) + 2 * t * (self.end.y - self.control.y);
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
        return arcLength / self.arcLength;
    } else {
        CGFloat nextArcLength = ((NSNumber*)self.guideArcLengths[index + 1]).floatValue;
        CGFloat arcLengthDiff = nextArcLength - arcLength;
        CGFloat tRatio = (t - tInc * index) / tInc;
        return (arcLength + arcLengthDiff * tRatio) / self.arcLength;
    }
}

- (CGFloat)tFromRatio:(CGFloat)ratio {
    CGFloat targetLength = ratio * self.arcLength;
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
