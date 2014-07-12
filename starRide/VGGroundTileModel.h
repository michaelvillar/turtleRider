//
//  VGGroundTileModel.h
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    VGKTilePositionFall,
    VGKTilePositionFound,
    VGKTilePositionNotFound
} VGkTilePositionResult;

@interface VGGroundTileModel : NSObject
@property (assign, readonly) CGPoint* extremityPoints;
@property (strong, readonly) NSMutableArray* curves;
@property (assign, readwrite) CGPoint position;

+ (VGGroundTileModel*)tileFromName:(NSString *)name;

- (NSMutableDictionary*)nextPositionInfo:(CGFloat)distance;
- (NSDictionary*)pointInfoBetweenOldPosition:(CGPoint)oldPosition newPosition:(CGPoint)newPosition;
- (BOOL)canJump;
@end
