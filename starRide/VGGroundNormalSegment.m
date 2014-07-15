//
//  VGGroundSegment.m
//  starRide
//
//  Created by Sebastien Villar on 09/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundNormalSegment.h"
#import "VGConstant.h"

@interface VGGroundNormalSegment ()
@property (strong, readonly) VGGroundNormalSegmentModel* model;
@end

@implementation VGGroundNormalSegment

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithModel:(VGGroundNormalSegmentModel*)model {
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
    CGPoint lastPoint = self.model.bezier.start;
    int segmentsCount = self.model.bezier.arcLength / VG_GROUND_SEGMENT_SIZE;
    
    for (CGFloat r = 0; r <= 1; r += 1.0 / segmentsCount) {
        CGPoint point = [self.model.bezier pointFromT:[self.model.bezier tFromRatio:r]];
        [self drawSegmentFrom:lastPoint to:point radius:1 color:[CCColor blackColor]];
        lastPoint = point;
    }
    
    [self drawSegmentFrom:lastPoint to:self.model.bezier.end radius:1 color:[CCColor blackColor]];
}




@end
