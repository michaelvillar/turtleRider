//
//  VGGroundCurve.m
//  starRide
//
//  Created by Sebastien Villar on 09/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundCurve.h"
#import "VGGroundNormalSegment.h"
#import "VGGroundLoopingSegment.h"
#import "VGGroundNormalSegmentModel.h"
#import "VGGroundLoopingSegmentModel.h"
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
        for (id<VGGroundSegmentModelProtocol> segmentModel in self.model.segments) {
            CCNode<VGGroundSegmentProtocol>* segment;
            if ([segmentModel isKindOfClass:VGGroundNormalSegmentModel.class])
                segment = [[VGGroundNormalSegment alloc] initWithModel:segmentModel];
            else if ([segmentModel isKindOfClass:VGGroundLoopingSegmentModel.class]) {
                segment = [[VGGroundLoopingSegment alloc] initWithModel:segmentModel];
            }
            
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
    for (CCNode<VGGroundSegmentProtocol>* segment in self.segments) {
        [segment drawModel];
    }
}

@end
