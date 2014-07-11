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
@property (strong, readonly) VGGroundSegmentModel* model;
@end

@implementation VGGroundSegment

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithModel:(VGGroundSegmentModel*)model {
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
}




@end
