//
//  PeripheralData.m
//  BlueToothLocator
//
//  Created by Chris Voronin on 10/1/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "PeripheralData.h"

@implementation PeripheralData

@synthesize peripheral, averageRSSI, que, index;

-(id)initWithPeripheral:(CBPeripheral*)p
{
    self = [super init];
    if (self)
    {
        self.peripheral = p;
        self.que = [[LNQue alloc] init];
        self.averageRSSI = -1000.0;

        NSString * intString = [p.name substringFromIndex:p.name.length - 2];
        if ([intString hasPrefix:@"0"])
            intString = [intString substringFromIndex:1];
        self.index = [intString intValue];
    }
    return self;
}

-(float)distanceFromRSSI
{
    // 50 @ 1
    // 65 @ 5
    float curr = self.averageRSSI;
    if (curr < 0)
        curr *= -1;
    
    if (curr < 50)
        return 1.0f;
    
    float slope = 4.0;
    float b = 50;
    // y = mx + b;
    // x = y - b / m
    float retVal = (curr - b) / slope;
    return retVal;
    
//    float y = self.averageRSSI;
//    float x = 0;
//    float A = 62;//54; // at 1 meter;
//    float n = 2.0;//2.8; // path loss
//    //y = -10n * log(x) - A;
//    
//    if (y >= -A)
//        return 1;
//    
//    float value = (y + A) / -(n * 10);
//    x = pow(10, value);
//    return x;

}

@end
