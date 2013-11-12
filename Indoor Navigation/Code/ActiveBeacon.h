//
//  ActiveBeacon.h
//  BlueToothLocator
//
//  Created by Chris Voronin on 10/11/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActiveBeacon : NSObject

@property (nonatomic, assign) int beaconID;
@property (nonatomic, assign) float distance;

-(id)initWithBeaconID:(int)b distance:(float)d;

@end
