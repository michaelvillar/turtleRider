//
//  VGFrontLayer.h
//  starRide
//
//  Created by Sebastien Villar on 08/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "CCNode.h"
#import "VGGameModel.h"

@interface VGFrontLayer : CCNode <VGGameModelDelegate>

- (id)initWithSize:(CGSize) size;

@end
