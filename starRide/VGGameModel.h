//
//  VGGameModel.h
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VGWorldModel.h"

@protocol VGGameModelDelegate <NSObject>

@end

@protocol VGWorldModelDelegate <NSObject>
- (void)didCreateGroundTile:(VGGroundTileModel*)tile atPosition:(CGPoint)position;
- (void)didRemoveGroundTile:(VGGroundTileModel*)tile;
- (void)characterDidMove:(CGPoint)position angle:(CGFloat)angle;
@end

@interface VGGameModel : NSObject
@property (strong, readonly) VGWorldModel* world;
@property (assign, readwrite) CGFloat speed;
@property (weak, readwrite) id gameDelegate;
@property (weak, readwrite) id worldDelegate;

- (void)update:(CCTime)dt;
@end
