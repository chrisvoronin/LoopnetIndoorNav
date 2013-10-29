//
//  DemoViewController.h
//  BlueToothLocator
//
//  Created by Chris Voronin on 10/1/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

#define BeaconNamePrefix @"csg-0000000000"

@interface DemoViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@end
