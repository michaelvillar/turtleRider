//
//  VGGroundCurveModel.h
//  starRide
//
//  Created by Sebastien Villar on 10/07/14.
//  Copyright (c) 2014 VillarGames. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    VGkCurvePositionNotFound,
    VGkCurvePositionFound
} VGkCurvePositionResult;

@interface VGGroundCurveModel : NSObject
@property (assign, readonly) CGPoint* extremityPoints;
@property (strong, readonly) NSMutableArray* segments;

- (id)initWithData:(NSDictionary *)data;
- (NSMutableDictionary*)nextPositionInfo:(CGFloat)distance info:(NSMutableDictionary*)info;
@end
