//
//  BeaconPair.h
//  Indoor Navigation
//
//  Created by Chris Voronin on 11/12/13.
//  Copyright (c) 2013 Better Web Now. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActiveBeacon.h"

@interface BeaconPair : NSObject

@property (nonatomic, assign) int count;
@property (nonatomic, strong) ActiveBeacon * beacon1;
@property (nonatomic, strong) ActiveBeacon * beacon2;

-(float)getMinDistance;
-(float)getAverageDistance;

-(int)confidenceValue;

-(CGRect)getRectFromBeaconPoints:(CGPoint)p1 and2:(CGPoint)p2 meterInPoints:(float)mip;

@end
