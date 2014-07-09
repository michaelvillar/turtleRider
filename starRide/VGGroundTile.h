//
//  VGGroundTile.h
//  starRide
//
//  Created by Sebastien Villar on 09/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "CCDrawNode.h"

@interface VGGroundTile : CCDrawNode
@property (assign, readonly) CGPoint startPoint;
@property (assign, readonly) CGPoint endPoint;

+ (VGGroundTile*)tileFromName:(NSString*)name;

- (NSValue*)nextPosition:(CGFloat)distance;
@end
