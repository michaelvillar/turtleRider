//
//  VGBezierModel.h
//  starRide
//
//  Created by Sebastien Villar on 15/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VGBezierModel : NSObject
@property (assign, readwrite) CGPoint start;
@property (assign, readwrite) CGPoint control;
@property (assign, readwrite) CGPoint end;

@property (assign, readonly) CGFloat arcLength;

- (id)initWithStart:(CGPoint)start control:(CGPoint)control end:(CGPoint)end arcLength:(CGFloat)arcLength;
- (CGFloat)tFromX:(CGFloat)x;
- (CGPoint)pointFromT:(CGFloat)t;
- (CGFloat)slopeFromT:(CGFloat)t;
- (CGFloat)ratioFromT:(CGFloat)t;
- (CGFloat)tFromRatio:(CGFloat)ratio;
@end
