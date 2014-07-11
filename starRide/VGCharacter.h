//
//  VGCharacter.h
//  starRide
//
//  Created by Sebastien Villar on 08/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "CCDrawNode.h"

@interface VGCharacter : CCDrawNode
@property (assign, readonly) CGPoint position;
@property (assign, readonly) CGFloat angle;

- (void)moveCharacterAtPosition:(CGPoint)position angle:(CGFloat)angle;
@end
