//
//  VGScaleGuideModel.m
//  starRide
//
//  Created by Sebastien Villar on 23/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGScaleGuideModel.h"

@interface VGScaleGuideModel ()

@end

@implementation VGScaleGuideModel

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithData:(NSDictionary*)data {
    self = [super init];
    if (self) {
        NSDictionary* position = data[@"position"];
        _position = CGPointMake(((NSNumber*)position[@"x"]).floatValue, -((NSNumber*)position[@"y"]).floatValue);
        _value = ((NSNumber*)data[@"value"]).floatValue;
    }
    return self;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

@end
