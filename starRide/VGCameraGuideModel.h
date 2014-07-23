//
//  VGCameraGuideModel.h
//  starRide
//
//  Created by Sebastien Villar on 23/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VGCameraGuideModel : NSObject
@property (assign, readonly) CGPoint position;

- (id)initWithData:(NSDictionary*)data;
@end
