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
@property (strong, readwrite) VGGroundSegment* currentSegment;
@property (assign, readwrite) CGPoint startPoint;
@property (assign, readwrite) CGPoint endPoint;

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

- (NSValue*)nextPosition:(CGFloat)distance {
    if (!self.currentSegment)
        self.currentSegment = self.segments[0];
    
    if (self.currentSegment) {
        NSValue* value = [self.currentSegment nextPosition:distance];
        if (value)
            return value;
        long index = [self.segments indexOfObject:self.currentSegment] + 1;
        if (index >= self.segments.count)
            return nil;
        
        distance -= self.currentSegment.remainingDistance;
        value = [self.segments[index] nextPosition:distance];
        if (value) {
            self.currentSegment = self.segments[index];
            return value;
        }
        else {
            self.currentSegment = nil;
            NSLog(@"Next point not found");
        }
    }
    return nil;
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
    
    self.startPoint = ((VGGroundSegment*)self.segments[0]).startPoint;
    self.endPoint = ((VGGroundSegment*)self.segments[self.segments.count - 1]).endPoint;
}

@end
