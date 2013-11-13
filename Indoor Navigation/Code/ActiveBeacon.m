//
//  ActiveBeacon.m
//  BlueToothLocator
//
//  Created by Chris Voronin on 10/11/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "ActiveBeacon.h"

@implementation ActiveBeacon

@synthesize beaconID, distance;

-(id)initWithBeaconID:(int)b distance:(float)d
{
    self = [super init];
    if (self)
    {
        self.beaconID = b;
        self.distance = d;
    }
    return self;
}

@end
