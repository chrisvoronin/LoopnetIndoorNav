//
//  BeaconCoordinates.h
//  BlueToothLocator
//
//  Created by Chris Voronin on 11/6/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeaconCoordinates : NSObject

@property(nonatomic, assign) CGPoint coordinate;
@property(nonatomic, assign) int beaconID;

-(id)initWithID:(int)bid andCoordinate:(CGPoint)coord;

@end
