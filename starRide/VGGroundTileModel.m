//
//  VGGroundTileModel.m
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundTileModel.h"
#import "VGGroundCurveModel.h"

@interface VGGroundTileModel ()
@property (assign, readwrite) int startCurveIndex;


- (id)initWithData:(NSDictionary*)data;
- (void)loadCurves:(NSDictionary*)data;
@end

@implementation VGGroundTileModel

////////////////////////////////
#pragma mark - Public
////////////////////////////////

+ (VGGroundTileModel*)tileFromName:(NSString *)name {
    NSString* path = [[NSBundle mainBundle] pathForResource:name
                                                     ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    
    NSError* e;
    id json = [NSJSONSerialization JSONObjectWithData:data options:nil error:&e];
    
    if (e || ![json isKindOfClass:NSDictionary.class]) {
        NSLog(@"%@", e);
        //To change
        NSException* exception = [NSException exceptionWithName:@"JSON serialization fail" reason:@"couldn't load json for tile" userInfo:nil];
        [exception raise];
        return nil;
    }
    
    return [[VGGroundTileModel alloc] initWithData:json];
}

- (NSMutableDictionary*)nextPositionInfo:(CGFloat)distance info:(NSMutableDictionary*)info {
    if (!info[@"curveIndex"])
        info[@"curveIndex"] = [NSNumber numberWithInt:self.startCurveIndex];

    int index = ((NSNumber*)info[@"curveIndex"]).intValue;
    
    VGGroundCurveModel* curve = self.curves[index];
    NSMutableDictionary* dic = [curve nextPositionInfo:distance info:info];
    if (!dic)
        return nil;
    
    switch (((NSNumber*)dic[@"positionResult"]).intValue) {
        case VGkCurvePositionFound: {
            dic[@"positionResult"] = [NSNumber numberWithInt:VGKTilePositionFound];
            return dic;
        }
            
        case VGkCurvePositionNotFound: {
            if (CGPointEqualToPoint(curve.extremityPoints[1], self.extremityPoints[1])) {
                dic[@"positionResult"] = [NSNumber numberWithInt:VGKTilePositionNotFound];
            } else {
                dic[@"positionResult"] = [NSNumber numberWithInt:VGKTilePositionFall];
            }
            return dic;
        }
            
        default:
            return nil;
    }
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (id)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _curves = [[NSMutableArray alloc] init];
        _extremityPoints = malloc(2 * sizeof(CGPoint));
        
        [self loadCurves:data];
    }
    return self;
}

- (void)loadCurves:(NSDictionary*)data {
    CGPoint start = CGPointMake(INFINITY, INFINITY);
    CGPoint end = CGPointMake(-INFINITY, -INFINITY);
    
    int i = 0;
    for (NSDictionary* curveDic in data[@"curves"]) {
        VGGroundCurveModel* curve = [[VGGroundCurveModel alloc] initWithData:curveDic];
        [self.curves addObject:curve];
        
        if (curve.extremityPoints[0].x < start.x) {
            self.startCurveIndex = i;
            start = curve.extremityPoints[0];
        }

        if (curve.extremityPoints[1].x > end.x)
            end = curve.extremityPoints[1];
        i++;
    }
    
    self.extremityPoints[0] = start;
    self.extremityPoints[1] = end;
}

@end
