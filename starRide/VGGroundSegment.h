//
//  VGGroundSegment.h
//  starRide
//
//  Created by Sebastien Villar on 09/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "CCDrawNode.h"

@interface VGGroundSegment : CCDrawNode
@property (assign, readonly) CGPoint startPoint;
@property (assign, readonly) CGPoint endPoint;
@property (assign, readonly) CGFloat remainingDistance;

- (id)initWithData:(NSDictionary*)data;
- (NSDictionary*)nextPosition:(CGFloat)distance;
@end
