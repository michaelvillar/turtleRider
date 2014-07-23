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

@protocol VGGameModelDelegate <NSObject>
- (void)didCreateGroundTile:(VGGroundTileModel*)tile atPosition:(CGPoint)position;
- (void)didRemoveGroundTile:(VGGroundTileModel*)tile;
- (void)characterDidMove:(CGPoint)position angle:(CGFloat)angle;
- (void)cameraDidMoveAtPosition:(CGPoint)position scale:(CGFloat)scale;
@end

@interface VGGameModel : NSObject <VGGroundModelDelegate>
@property (weak, readwrite) id delegate;

- (id)initWithSize:(CGSize)size;
- (void)update:(CCTime)dt;
@end
