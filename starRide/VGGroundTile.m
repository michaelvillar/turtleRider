//
//  VGGroundTile.m
//  starRide
//
//  Created by Sebastien Villar on 09/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundTile.h"
#import "VGGroundCurve.h"

@interface VGGroundTile ()
@property (strong, readonly) NSDictionary* data;
@property (strong, readonly) NSMutableArray* curves;
@property (strong, readwrite) VGGroundCurve* currentCurve;
@property (assign, readwrite) CGPoint startPoint;
@property (assign, readwrite) CGPoint endPoint;

- (id)initWithData:(NSDictionary*)data;
- (void)loadCurves;
@end

@implementation VGGroundTile

////////////////////////////////
#pragma mark - Public
////////////////////////////////

+ (VGGroundTile*)tileFromName:(NSString *)name {
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
    
    return [[VGGroundTile alloc] initWithData:json];
}

- (NSValue*)nextPosition:(CGFloat)distance {
    if (!self.currentCurve) {
        self.currentCurve = self.curves[0];
    }
    if (self.currentCurve) {
        NSValue* value = [self.currentCurve nextPosition:distance];
        if (value) {
            return value;
        }
    }
    return nil;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (id)initWithData:(NSDictionary*)data {
    self = [super init];
    if (self) {
        _data = data;
        _curves = [[NSMutableArray alloc] init];
    
        [self loadCurves];
        
        _currentCurve = self.curves[0];
    }
    return self;
}

- (void)loadCurves {
    self.startPoint = CGPointMake(INFINITY, INFINITY);
    self.endPoint = CGPointMake(-INFINITY, -INFINITY);
    
    for (NSDictionary* curveDic in self.data[@"curves"]) {
        VGGroundCurve* curve = [[VGGroundCurve alloc] initWithData:curveDic];
        [self addChild:curve z:0];
        [self.curves addObject:curve];
        
        if (curve.startPoint.x < self.startPoint.x)
            self.startPoint = curve.startPoint;
        
        if (curve.endPoint.x > self.endPoint.x)
            self.endPoint = curve.endPoint;
    }
}

@end
