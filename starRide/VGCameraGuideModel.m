//
//  VGCameraGuideModel.m
//  starRide
//
//  Created by Sebastien Villar on 23/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGCameraGuideModel.h"

@interface VGCameraGuideModel ()
@end

@implementation VGCameraGuideModel

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithData:(NSDictionary*)data {
    self = [super init];
    if (self) {
        NSDictionary* position = data[@"position"];
        _position = CGPointMake(((NSNumber*)position[@"x"]).floatValue, -((NSNumber*)position[@"y"]).floatValue);
    }
    return self;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

@end
