//
//  VGGameModel.h
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VGWorldModel.h"

@interface VGGameModel : NSObject
@property (strong, readonly) VGWorldModel* world;
@property (assign, readwrite) CGFloat speed;
@end
