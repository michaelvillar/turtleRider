//
//  VGGroundSegmentModelProtocol.h
//  starRide
//
//  Created by Sebastien Villar on 12/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VGGroundSegmentModelProtocol <NSObject>
@property (assign, readonly) CGPoint* extremityPoints;

- (id)initWithData:(NSDictionary *)data;
- (NSDictionary*)nextPositionInfo:(CGFloat)distance;
- (NSDictionary*)pointInfoBetweenOldPosition:(CGPoint)oldPosition newPosition:(CGPoint)newPosition;
- (CGFloat)tFromRatio:(CGFloat)ratio;
- (CGPoint)pointFromT:(CGFloat)t;
@end
