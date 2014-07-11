//
//  VGGameModel.m
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import "VGGameModel.h"

@interface VGGameModel ()
@end

@implementation VGGameModel

////////////////////////////////
#pragma mark - Public
////////////////////////////////

- (id)init {
    self = [super init];
    if (self) {
        _speed = 300;
        _world = [[VGWorldModel alloc] initWithGame:self];
    }
    return self;
}

- (id)worldDelegate {
    return self.world.delegate;
}

- (void)setWorldDelegate:(id)worldDelegate {
    self.world.delegate = worldDelegate;
}

////////////////////////////////
#pragma mark - Private
////////////////////////////////

- (void)update:(CCTime)dt {
    [self.world update:dt];
}

@end
