//
//  BeaconCoordinates.m
//  BlueToothLocator
//
//  Created by Chris Voronin on 11/6/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "BeaconCoordinates.h"

@implementation BeaconCoordinates

-(id)initWithID:(int)bid andCoordinate:(CGPoint)coord
{
    self = [super init];
    if (self)
    {
        self.beaconID = bid;
        self.coordinate = coord;
    }
    return self;
}

@end
