//
//  VGGroundLoopingSegment.h
//  starRide
//
//  Created by Sebastien Villar on 12/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "CCDrawNode.h"
#import "VGGroundSegmentProtocol.h"
#import "VGGroundLoopingSegmentModel.h"

@interface VGGroundLoopingSegment : CCDrawNode <VGGroundSegmentProtocol>
- (id)initWithModel:(VGGroundLoopingSegmentModel*)model;
@end
