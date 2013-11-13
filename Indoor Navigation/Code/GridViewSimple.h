//
//  GridViewSimple.h
//  BlueToothLocator
//
//  Created by Chris Voronin on 11/7/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridViewSimple : UIView
{
    NSMutableArray * beaconCoordinates;
}

-(void)setBeacons:(NSArray*)beaconCoordinatesArray;

@end
