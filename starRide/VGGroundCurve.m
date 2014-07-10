//
//  VGGroundCurve.m
//  starRide
//
//  Created by Sebastien Villar on 09/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundCurve.h"
#import "VGGroundSegment.h"
#import "VGConstant.h"

@interface VGGroundCurve ()
@property (strong, readonly) VGGroundCurveModel* model;
@property (strong, readonly) NSMutableArray* segments;
@end

@implementation VGGroundCurve

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithModel:(VGGroundCurveModel*)model {
    self = [super init];
    if (self) {
        _model = model;
        _segments = [[NSMutableArray alloc] init];
        for (VGGroundSegmentModel* segmentModel in self.model.segments) {
            VGGroundSegment* segment = [[VGGroundSegment alloc] initWithModel:segmentModel];
            [_segments addObject:segment];
            [self addChild:segment z:0];
        }
    }
    return self;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)drawModel {
    for (VGGroundSegment* segment in self.segments) {
        [segment drawModel];
    }
}

@end
