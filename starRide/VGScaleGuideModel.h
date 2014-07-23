//
//  VGScaleGuideModel.h
//  starRide
//
//  Created by Sebastien Villar on 23/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VGScaleGuideModel : NSObject
@property (assign, readonly) CGPoint position;
@property (assign, readonly) CGFloat value;

- (id)initWithData:(NSDictionary*)data;
@end
