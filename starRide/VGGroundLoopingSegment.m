//
//  VGGroundLoopingSegment.m
//  starRide
//
//  Created by Sebastien Villar on 12/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundLoopingSegment.h"
#import "VGGroundNormalSegmentModel.h"
#import "VGConstant.h"

@interface VGGroundLoopingSegment ()
@property (strong, readonly) VGGroundLoopingSegmentModel* model;
@end

@implementation VGGroundLoopingSegment

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithModel:(VGGroundLoopingSegmentModel*)model {
    self = [super init];
    if (self) {
        _model = model;
    }
    return self;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)drawModel {
    VGGroundNormalSegmentModel* segment;
    for (int i = 0; i < self.model.segments.count; i++) {
        segment = self.model.segments[i];
        
        CGPoint lastPoint = segment.bezier.start;
        int segmentsCount = segment.bezier.arcLength / VG_GROUND_SEGMENT_SIZE;
        
        for (CGFloat r = 0; r <= 1; r += 1.0 / segmentsCount) {
            CGPoint point = [segment.bezier pointFromT:[segment.bezier tFromRatio:r]];
            [self drawSegmentFrom:lastPoint to:point radius:1 color:[CCColor blackColor]];
            lastPoint = point;
        }
        [self drawSegmentFrom:lastPoint to:segment.bezier.end radius:1 color:[CCColor blackColor]];
    }
    
//    CCColor* color;
//    for (CGFloat r = 0; r <= 1; r += 1.0 / segmentsCount) {
//        CGFloat t = [self.model tFromRatio:r];
//        CGPoint point = [self.model pointFromT:t];
//        if (t >= self.model.loopingEntranceTs[0] && t <= self.model.loopingEntranceTs[1])
//            color = [CCColor greenColor];
//        else
//            color = [CCColor blackColor];
//        [self drawSegmentFrom:lastPoint to:point radius:1 color:color];
//        lastPoint = point;
//    }
    
    CGFloat angleSpan = (self.model.circleEndAngle - self.model.circleStartAngle);
    CGFloat perimeter = self.model.circleRadius * angleSpan;
    int segmentsCount = perimeter / VG_GROUND_SEGMENT_SIZE;
    CGFloat daInc = angleSpan / segmentsCount;
    CGPoint lastPoint = ((VGGroundNormalSegmentModel*)self.model.segments[1]).bezier.end;
    
    for (CGFloat da = daInc; da <= angleSpan; da += daInc) {
        CGPoint point = CGPointMake(self.model.circleCenter.x + cosf(da) * self.model.circleRadius,
                                    self.model.circleCenter.y + sinf(da) * self.model.circleRadius);
        [self drawSegmentFrom:lastPoint to:point radius:1 color:[CCColor blackColor]];
        lastPoint = point;
    }
}

@end
