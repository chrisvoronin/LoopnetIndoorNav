//
//  LocationUtility.h
//  BlueToothLocator
//
//  Created by Chris Voronin on 11/6/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeaconCoordinates.h"

@protocol LocationUtilityProtocol <NSObject>

-(void)cameNearBeaconID:(int)beaconID;

@end

@interface LocationUtility : NSObject
{
    float meterInPixels, maxWidth;
    
    CGRect priorRect;
    bool foundCloseOne;
    NSMutableDictionary * beaconCoordinates;
    CGPoint ptTopLeft, ptBottomRight;
}

@property (weak) id<LocationUtilityProtocol> delegate;

-(id)initWithMaxWidth:(float)max andMeterInPixels:(float)mip;


-(CGRect)getRectFromActiveBeacons:(NSArray*)beacons;

-(void)setBeacons:(NSArray*)beaconCoordinatesArray;


@end
