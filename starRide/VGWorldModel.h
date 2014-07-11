//
//  VGWorldModel.h
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "VGGroundModel.h"

@class VGGameModel;

@interface VGWorldModel : NSObject <VGGroundModelDelegate>
@property (weak, readonly) VGGameModel* game;
@property (weak, readwrite) id delegate;

- (id)initWithGame:(VGGameModel*)game;
- (void)update:(CCTime)dt;
@end
