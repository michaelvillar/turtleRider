//
//  VGCharacterModel.h
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface VGCharacterModel : NSObject
@property (assign, readwrite) CGPoint position;
@property (assign, readwrite) CGFloat angle;
@property (assign, readwrite) CGPoint velocity;
@property (assign, readwrite, getter = isJumping) BOOL jumping;
@end
