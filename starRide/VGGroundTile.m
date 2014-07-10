//
//  VGGroundTile.m
//  starRide
//
//  Created by Sebastien Villar on 09/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGroundTile.h"
#import "VGGroundCurve.h"
#import "VGConstant.h"

@interface VGGroundTile ()
@property (strong, readonly) VGGroundTileModel* model;
@property (strong, readonly) NSMutableArray* curves;
@end

@implementation VGGroundTile

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)initWithModel:(VGGroundTileModel*)model {
    self = [super init];
    if (self) {
        _model = model;
        _curves = [[NSMutableArray alloc] init];
        for (VGGroundCurveModel* curveModel in self.model.curves) {
            VGGroundCurve* curve = [[VGGroundCurve alloc] initWithModel:curveModel];
            [_curves addObject:curve];
            [self addChild:curve z:0];
        }
    }
    return self;
}

- (CGPoint*)extremityPoints {
    return self.model.extremityPoints;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)drawModel {
    for (VGGroundCurve* curve in self.curves) {
        [curve drawModel];
    }
}

@end
