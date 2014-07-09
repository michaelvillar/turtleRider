//
//  VGGroundCurve.m
//  starRide
//
//  Created by Sebastien Villar on 09/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundCurve.h"
#import "VGGroundSegment.h"

@interface VGGroundCurve ()
@property (strong, readonly) NSDictionary* data;
@property (strong, readonly) NSMutableArray* segments;

- (void)loadSegments;
@end

@implementation VGGroundCurve

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithData:(NSDictionary*)data {
    self = [super init];
    if (self) {
        _data = data;
        _segments = [[NSMutableArray alloc] init];
        
        [self loadSegments];
    }
    return self;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)loadSegments {
    for (NSDictionary* segmentDic in self.data[@"segments"]) {
        VGGroundSegment* segment = [[VGGroundSegment alloc] initWithData:segmentDic];
        [self addChild:segment z:0];
        [self.segments addObject:segment];
    }
}

@end
