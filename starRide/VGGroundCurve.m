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
        
        _currentSegment = _segments[0];
    }
    return self;
}

- (NSDictionary*)nextPosition:(CGFloat)distance {
    NSDictionary* dic;
    
    if (!self.currentSegment || !(dic = [self.currentSegment nextPosition:distance]))
        return nil;
    
    NSMutableDictionary* newDic = [[NSMutableDictionary alloc] init];
    switch (((NSNumber*)dic[@"positionType"]).intValue) {
        case VGkPointOnSegment: {
            newDic[@"positionType"] = [[NSNumber alloc] initWithInt:VGkPointOnCurve];
            newDic[@"position"] = dic[@"position"];
            return newDic;
        }
            
        case VGkPointOffSegment: {
            long index = [self.segments indexOfObject:self.currentSegment] + 1;
            if (index >= self.segments.count) {
                newDic[@"positionType"] = [[NSNumber alloc] initWithInt:VGkPointOffCurve];
                newDic[@"lastPoint"] = [NSValue valueWithCGPoint:self.currentSegment.endPoint];
                self.currentSegment = nil;
                return newDic;
            }
            self.currentSegment = [self.segments objectAtIndex:index];
            return [self nextPosition:distance - ((NSNumber*)dic[@"distanceRemaining"]).floatValue];
        }
            
        default: 
            return nil;
    }
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
