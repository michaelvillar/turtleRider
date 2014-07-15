//
//  VGCharacter.m
//  starRide
//
//  Created by Sebastien Villar on 08/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGCharacter.h"
#import "VGConstant.h"

@interface VGCharacter ()
@property (assign, readwrite) CGPoint position;

@end

@implementation VGCharacter

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)init {
    self = [super init];
    if (self) {
        if (VG_DEBUG_MODE) {
            CGPoint points[] = {
                CGPointMake(0, 0),
                CGPointMake(50, 0),
                CGPointMake(50, 25),
                CGPointMake(0, 25)
            };
            
            [self drawPolyWithVerts:points
                              count:4
                          fillColor:nil
                        borderWidth:1
                        borderColor:[CCColor colorWithWhite:0 alpha:1]];
            self.contentSize = CGSizeMake(50, 25);
        } else {
            [self drawDot:CGPointMake(16, 16) radius:16 color:[CCColor redColor]];
            self.contentSize = CGSizeMake(32, 32);
        }
        self.anchorPoint = CGPointMake(0.5, 0.0);
    }
    return self;
}

- (CGFloat)angle {
    return -self.rotation * M_PI / 180;
}

- (void)moveCharacterAtPosition:(CGPoint)position angle:(CGFloat)angle {
    self.position = position;
    self.rotation = -angle * 180 / M_PI;
}

////////////////////////////////
#pragma mark - Cocos2D
////////////////////////////////

@end
