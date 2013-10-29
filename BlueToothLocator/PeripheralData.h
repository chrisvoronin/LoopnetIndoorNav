//
//  PeripheralData.h
//  BlueToothLocator
//
//  Created by Chris Voronin on 10/1/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LNQue.h"

@interface PeripheralData : NSObject

@property (atomic, strong) CBPeripheral *peripheral;
@property (atomic, assign) float averageRSSI;
@property (atomic, strong) LNQue * que;
@property (atomic, assign) int index;

-(id)initWithPeripheral:(CBPeripheral*)p;

-(float)distanceFromRSSI;

@end
