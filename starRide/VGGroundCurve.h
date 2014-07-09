//
//  VGGroundCurve.h
//  starRide
//
//  Created by Sebastien Villar on 09/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "CCDrawNode.h"

@interface VGGroundCurve : CCDrawNode
@property (assign, readonly) CGPoint startPoint;
@property (assign, readonly) CGPoint endPoint;

- (id)initWithData:(NSDictionary*)data;
- (NSDictionary*)nextPosition:(CGFloat)distance;
@end
