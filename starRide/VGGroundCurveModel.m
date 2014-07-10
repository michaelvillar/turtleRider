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
        
        [self loadSegments:data];
    }
    return self;
}

- (NSMutableDictionary*)nextPositionInfo:(CGFloat)distance info:(NSMutableDictionary*)info {
    if (!info[@"segmentIndex"])
        info[@"segmentIndex"] = @0;
    
    int index = ((NSNumber*)info[@"segmentIndex"]).intValue;
    VGGroundSegmentModel* segment = self.segments[index];
    NSMutableDictionary* dic = [segment nextPositionInfo:distance info:info];
    if (!dic)
        return nil;
    
    switch (((NSNumber*)dic[@"positionResult"]).intValue) {
        case VGkSegmentPositionFound: {
            dic[@"positionResult"] = [[NSNumber alloc] initWithInt:VGkCurvePositionFound];
            dic[@"position"] = dic[@"position"];
            return dic;
        }
            
        case VGkSegmentPositionNotFound: {
            index++;
            if (index >= self.segments.count) {
                dic[@"positionResult"] = [[NSNumber alloc] initWithInt:VGkCurvePositionNotFound];
                dic[@"position"] = [NSValue valueWithCGPoint:segment.extremityPoints[1]];
                dic[@"distanceRemaining"] = [NSNumber numberWithFloat:distance - ((NSNumber*)dic[@"distanceRemaining"]).floatValue];
                return dic;
            }
            
            dic[@"segmentIndex"] = [NSNumber numberWithInt:(int)index];
            dic[@"segmentArc"] = @0;
            
            return [self nextPositionInfo:distance - ((NSNumber*)dic[@"distanceRemaining"]).floatValue info:dic];
        }
            
        default:
            return nil;
    }

    
    
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
