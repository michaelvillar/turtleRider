//
//  VGGroundSegment.h
//  starRide
//
//  Created by Sebastien Villar on 09/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "CCDrawNode.h"
#import "VGGroundSegmentModel.h"

@interface VGGroundSegment : CCDrawNode
- (id)initWithModel:(VGGroundSegmentModel*)model;
- (void)drawModel;
@end
