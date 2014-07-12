//
//  VGGroundSegment.h
//  starRide
//
//  Created by Sebastien Villar on 09/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "CCDrawNode.h"
#import "VGGroundSegmentProtocol.h"
#import "VGGroundNormalSegmentModel.h"

@interface VGGroundNormalSegment : CCDrawNode <VGGroundSegmentProtocol>
- (id)initWithModel:(VGGroundNormalSegmentModel*)model;
@end
