//
//  VGGroundCurve.h
//  starRide
//
//  Created by Sebastien Villar on 09/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "CCDrawNode.h"
#import "VGGroundCurveModel.h"

@interface VGGroundCurve : CCDrawNode
- (id)initWithModel:(VGGroundCurveModel*)model;
- (void)drawModel;
@end
