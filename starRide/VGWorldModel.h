//
//  VGWorldModel.h
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class VGGameModel;

@interface VGWorldModel : NSObject
@property (weak, readonly) VGGameModel* game;
@property (strong, readonly) NSMutableArray* tiles;
@property (assign, readonly) CGPoint characterPosition;

- (id)initWithGame:(VGGameModel*)game;
- (void)update:(CCTime)dt;
@end
