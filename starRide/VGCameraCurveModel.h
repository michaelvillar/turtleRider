//
//  VGCameraCurveModel.h
//  starRide
//
//  Created by Sebastien Villar on 23/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VGCameraCurveModel : NSObject
- (id)initWithData:(NSDictionary*)data;
- (NSDictionary*)cameraPositionInfoForX:(CGFloat)x;
@end
