//
//  VGGroundCurveModel.m
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundCurveModel.h"
#import "VGGroundSegmentModel.h"

@interface VGGroundCurveModel ()
@property (assign, readwrite) int currentSegmentIndex;

- (id)initWithData:(NSDictionary*)data;
- (void)loadSegments:(NSDictionary*)data;
@end

@implementation VGGroundCurveModel

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _segments = [[NSMutableArray alloc] init];
        _extremityPoints = malloc(2 * sizeof(CGPoint));
        _currentSegmentIndex = 0;
        
        [self loadSegments:data];
    }
    return self;
}

- (NSDictionary*)nextPositionInfo:(CGFloat)distance {
    VGGroundSegmentModel* segment = self.segments[self.currentSegmentIndex];
    NSDictionary* dic = [segment nextPositionInfo:distance];
    
    if (((NSNumber*)dic[@"positionFound"]).boolValue) {
        return dic;
    } else if (self.currentSegmentIndex + 1 < self.segments.count){
        self.currentSegmentIndex++;
        return [self nextPositionInfo:((NSNumber*)dic[@"distanceRemaining"]).floatValue];
    } else {
        return dic;
    }
    return nil;
}

- (NSDictionary*)pointInfoBetweenOldPosition:(CGPoint)oldPosition newPosition:(CGPoint)newPosition {
    VGGroundSegmentModel* segment;
    VGGroundSegmentModel* currentSegment;
    int i;
    for (i = self.currentSegmentIndex; i < self.segments.count; i++) {
        currentSegment = self.segments[i];
        if (newPosition.x >= currentSegment.extremityPoints[0].x && newPosition.x <= currentSegment.extremityPoints[1].x) {
            segment = currentSegment;
            break;
        }
    }
    
    if (!segment)
        return [[NSDictionary alloc] initWithObjectsAndKeys:@"positionFound", @(false), nil];
    
    NSDictionary* dic = [segment pointInfoBetweenOldPosition:oldPosition newPosition:newPosition];
    if (((NSNumber*)dic[@"positionFound"]).boolValue) {
        self.currentSegmentIndex = i;
    }
    return dic;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)loadSegments:(NSDictionary *)data {
    
    for (NSDictionary* segmentDic in data[@"segments"]) {
        VGGroundSegmentModel* segment = [[VGGroundSegmentModel alloc] initWithData:segmentDic];
        [self.segments addObject:segment];
    }
    
    self.extremityPoints[0] = ((VGGroundSegmentModel*)self.segments[0]).extremityPoints[0];
    self.extremityPoints[1] = ((VGGroundSegmentModel*)self.segments[self.segments.count - 1]).extremityPoints[1];
}

@end
