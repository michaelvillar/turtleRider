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

static const CGFloat VGk_LOOPING_START_DISTANCE = 50;

@interface VGGroundLoopingSegment ()
@property (strong, readonly) VGGroundLoopingSegmentModel* model;
@property (assign, readwrite, getter = isUpdated) BOOL updated;
@end

@implementation VGGroundLoopingSegment

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithModel:(VGGroundLoopingSegmentModel*)model {
    self = [super init];
    if (self) {
        _model = model;
        _updated = false;
    }
    return self;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)draw {
    [super draw];
    
    if (self.model.isLoopingEnabled && !self.isUpdated) {
        [self clear];
        [self drawModel];
        self.updated = true;
    }
}

- (void)drawModel {
    if (self.model.isLoopingEnabled) {
        VGGroundNormalSegmentModel* segment;
        CCColor* color = [CCColor blackColor];
        for (int i = 0; i < self.model.segments.count; i++) {
            segment = self.model.segments[i];
            
            CGPoint lastPoint = segment.bezier.start;
            int segmentsCount = segment.bezier.arcLength / VG_GROUND_SEGMENT_SIZE;
            
            for (CGFloat r = 0; r <= 1; r += 1.0 / segmentsCount) {
                CGFloat t = [segment.bezier tFromRatio:r];
                if (VG_DEBUG_MODE && i == 0) {
                    if (t >= self.model.loopingEntranceTs[0] && t <= self.model.loopingEntranceTs[1])
                        color = [CCColor greenColor];
                    else
                        color = [CCColor blackColor];
                }
                CGPoint point = [segment.bezier pointFromT:t];
                [self drawSegmentFrom:lastPoint to:point radius:1 color:color];
                lastPoint = point;
            }
            [self drawSegmentFrom:lastPoint to:segment.bezier.end radius:1 color:[CCColor blackColor]];
        }
        
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
    } else {
        for (int i = 0; i < 2; i++) {
            CGFloat maxRatio;
            int segmentsCount;
            VGGroundNormalSegmentModel* segment = self.model.segments[i];
            CGPoint lastPoint = segment.bezier.start;
            CCColor* color;
            
            if (i == 0) {
                maxRatio = 1.0;
                segmentsCount = segment.bezier.arcLength / VG_GROUND_SEGMENT_SIZE;
            } else {
                maxRatio = VGk_LOOPING_START_DISTANCE / segment.bezier.arcLength;
                segmentsCount = VGk_LOOPING_START_DISTANCE / VG_GROUND_SEGMENT_SIZE;
            }
            
            for (CGFloat r = 0; r <= maxRatio; r += maxRatio / segmentsCount) {
                CGFloat t = [segment.bezier tFromRatio:r];
                if (VG_DEBUG_MODE) {
                    if (t >= self.model.loopingEntranceTs[0] && t <= self.model.loopingEntranceTs[1])
                        color = [CCColor greenColor];
                    else
                        color = [CCColor blackColor];
                }
                CGPoint point = [segment.bezier pointFromT:t];
                [self drawSegmentFrom:lastPoint to:point radius:1 color:color];
                lastPoint = point;
            }
        }
    }
}

@end
