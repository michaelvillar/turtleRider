//
//  VGGroundTileModel.h
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VGGroundTileModel : NSObject
@property (assign, readonly) CGPoint* extremityPoints;
@property (assign, readwrite) CGPoint position;
@property (strong, readonly) NSMutableArray* curves;

+ (VGGroundTileModel*)tileFromName:(NSString *)name;

- (NSMutableDictionary*)nextPositionInfo:(CGFloat)distance;
- (NSDictionary*)pointInfoBetweenOldPosition:(CGPoint)oldPosition newPosition:(CGPoint)newPosition;
- (NSValue*)cameraPositionForX:(CGFloat)x;
- (BOOL)canJump;
- (void)enterLooping;
@end
