//
//  VGCameraCurveModel.m
//  starRide
//
//  Created by Sebastien Villar on 23/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGCameraCurveModel.h"
#import "VGBezierModel.h"
#import "VGScaleGuideModel.h"
#import "VGCameraGuideModel.h"
#import "VGCameraCurveModel.h"
#import "VGConstant.h"

@interface VGCameraCurveModel ()
@property (strong, readonly) NSMutableArray* beziers;
@property (strong, readonly) NSMutableArray* scaleGuides;
@property (strong, readonly) NSMutableArray* cameraGuides;

- (CGPoint)positionForX:(CGFloat)x;
- (CGFloat)scaleForX:(CGFloat)x;
@end

@implementation VGCameraCurveModel

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithData:(NSDictionary*)data {
    self = [super init];
    if (self) {
        _beziers = [[NSMutableArray alloc] init];
        for (NSDictionary* segmentDic in data[@"segments"]) {
            CGPoint start = CGPointMake(((NSNumber*)segmentDic[@"bezier"][@"start"][@"x"]).floatValue,
                                        -((NSNumber*)segmentDic[@"bezier"][@"start"][@"y"]).floatValue);
            CGPoint control = CGPointMake(((NSNumber*)segmentDic[@"bezier"][@"control"][@"x"]).floatValue,
                                          -((NSNumber*)segmentDic[@"bezier"][@"control"][@"y"]).floatValue);
            CGPoint end = CGPointMake(((NSNumber*)segmentDic[@"bezier"][@"end"][@"x"]).floatValue,
                                      -((NSNumber*)segmentDic[@"bezier"][@"end"][@"y"]).floatValue);
            CGFloat arcLength = ((NSNumber*)data[@"bezier"][@"arc_length"]).floatValue;
            
            VGBezierModel* bezier = [[VGBezierModel alloc] initWithStart:start control:control end:end arcLength:arcLength];
            [_beziers addObject:bezier];
        }
        
        _scaleGuides = [[NSMutableArray alloc] init];
        for (NSDictionary* scaleGuidesDic in data[@"scale_guides"]) {
            VGScaleGuideModel* guide = [[VGScaleGuideModel alloc] initWithData:scaleGuidesDic];
            [_scaleGuides addObject:guide];
        }
        
        _cameraGuides = [[NSMutableArray alloc] init];
        for (NSDictionary* cameraGuidesDic in data[@"camera_guides"]) {
            VGCameraGuideModel* guide = [[VGCameraGuideModel alloc] initWithData:cameraGuidesDic];
            [_cameraGuides addObject:guide];
        }
    }
    return self;
}

- (NSDictionary*)cameraPositionInfoForX:(CGFloat)x {
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
    CGPoint point = [self positionForX:x];
    CGFloat scale = [self scaleForX:x];
    point = CGPointMake(point.x - VG_CHARACTER_INIT_POSITION.x / scale, point.y - VG_CHARACTER_INIT_POSITION.y / scale);
    dic[@"position"] = [NSValue valueWithCGPoint:point];
    dic[@"scale"] = @(scale);
    return dic;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (CGPoint)positionForX:(CGFloat)x {
    int beforeCount = 0;
    VGCameraGuideModel* preLastGuide;
    VGCameraGuideModel* lastGuide;
    for (VGCameraGuideModel* guide in self.cameraGuides) {
        if (guide.position.x <= x) {
            beforeCount++;
            if (!lastGuide || guide.position.x > lastGuide.position.x) {
                preLastGuide = lastGuide;
                lastGuide = guide;
            }
        }
    }
    
    if (beforeCount % 2 == 0) {
        CGFloat span = VG_CAMERA_GUIDE_SPAN;
        CGFloat spanRemaining = ((VGBezierModel*)self.beziers[self.beziers.count - 1]).end.x - lastGuide.position.x;
        if (spanRemaining < span)
            span = spanRemaining;

        if (x <= lastGuide.position.x + span) {
            CGFloat ratio = (x - lastGuide.position.x) / span;
            CGPoint point = CGPointMake(preLastGuide.position.x + (lastGuide.position.x - preLastGuide.position.x) * ratio
                                        + (x - lastGuide.position.x),
                                        preLastGuide.position.y + (lastGuide.position.y - preLastGuide.position.y) * ratio
                                        + ([self pointForX:x].y - lastGuide.position.y));
            return point;
        } else {
            return [self pointForX:x];
        }
    } else {
        return lastGuide.position;
    }
    return CGPointZero;
}

- (CGFloat)scaleForX:(CGFloat)x {
    VGScaleGuideModel* leftGuide;
	VGScaleGuideModel* rightGuide;
	for (VGScaleGuideModel* guide in self.scaleGuides) {
		if (guide.position.x <= x && (!leftGuide || leftGuide.position.x < guide.position.x))
			leftGuide = guide;
		if (guide.position.x >= x && (!rightGuide || rightGuide.position.x > guide.position.x)) {
			rightGuide = guide;
        }
	}
    
	if (leftGuide.position.x == rightGuide.position.x)
		return leftGuide.value;
    
    CGFloat ratio = (x - leftGuide.position.x) / (rightGuide.position.x - leftGuide.position.x);
    
	return leftGuide.value + ratio * (rightGuide.value - leftGuide.value);
}

- (CGPoint)pointForX:(CGFloat)x {
    for (int i = 0; i < self.beziers.count; i++) {
        VGBezierModel* bezier = self.beziers[i];
        if (x >= bezier.start.x && x <= bezier.end.x) {
            CGFloat t = [bezier tFromX:x];
            CGPoint point = [bezier pointFromT:t];
            return point;
        }
    }
    return CGPointZero;
}

@end
