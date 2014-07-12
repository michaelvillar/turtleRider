//
//  VGGroundLoopingSegment.m
//  starRide
//
//  Created by Sebastien Villar on 12/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundLoopingSegment.h"
#import "VGGroundLoopingSegmentModel.h"
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
    CGPoint lastPoint = self.model.bezierPoints[0];
    int segmentsCount = self.model.totalArcLength / VG_GROUND_SEGMENT_SIZE;
    
    for (CGFloat r = 0; r <= 1; r += 1.0 / segmentsCount) {
        CGPoint point = [self.model pointFromT:[self.model tFromRatio:r]];
        [self drawSegmentFrom:lastPoint to:point radius:1 color:[CCColor blackColor]];
        lastPoint = point;
    }
    
    [self drawSegmentFrom:lastPoint to:self.model.bezierPoints[2] radius:1 color:[CCColor blackColor]];
    
    CGFloat perimeter = self.model.loopingRadius * 2 * M_PI;
    segmentsCount = perimeter / VG_GROUND_SEGMENT_SIZE;
    CGFloat daInc = 2 * M_PI / segmentsCount;
    lastPoint = CGPointMake(self.model.loopingCenter.x + self.model.loopingRadius, self.model.loopingCenter.y);
    
    for (CGFloat da = daInc; da <= 2 * M_PI; da += daInc) {
        CGPoint point = CGPointMake(self.model.loopingCenter.x + cosf(da) * self.model.loopingRadius,
                                    self.model.loopingCenter.y + sinf(da) * self.model.loopingRadius);
        [self drawSegmentFrom:lastPoint to:point radius:1 color:[CCColor blackColor]];
        lastPoint = point;
    }
    [self drawSegmentFrom:CGPointMake(self.model.loopingCenter.x + self.model.loopingRadius, self.model.loopingCenter.y) to:lastPoint radius:1 color:[CCColor blackColor]];
}

@end
