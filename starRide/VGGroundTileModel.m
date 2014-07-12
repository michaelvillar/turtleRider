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
@property (assign, readwrite) int currentCurveIndex;

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

- (NSDictionary*)nextPositionInfo:(CGFloat)distance {
    VGGroundCurveModel* curve = self.curves[self.currentCurveIndex];
    return [curve nextPositionInfo:distance];
}

- (NSDictionary*)pointInfoBetweenOldPosition:(CGPoint)oldPosition newPosition:(CGPoint)newPosition {
    VGGroundCurveModel* curve;
    VGGroundCurveModel* currentCurve;
    int i;
    for (i = 0; i < self.curves.count; i++) {
        currentCurve = self.curves[i];
        if (newPosition.x >= currentCurve.extremityPoints[0].x && newPosition.x <= currentCurve.extremityPoints[1].x) {
            curve = currentCurve;
            NSDictionary* dic = [curve pointInfoBetweenOldPosition:oldPosition newPosition:newPosition];
            if (((NSNumber*)dic[@"positionFound"]).boolValue) {
                self.currentCurveIndex = i;
                return dic;
            }
        }
    }
    
    return [[NSDictionary alloc] initWithObjectsAndKeys:@"positionFound", @(false), nil];
}

- (BOOL)canJump {
    return [self.curves[self.currentCurveIndex] canJump];
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
        _currentCurveIndex = _startCurveIndex;
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
