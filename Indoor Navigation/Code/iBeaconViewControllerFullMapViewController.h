//
//  iBeaconViewControllerFullMapViewController.h
//  BlueToothLocator
//
//  Created by Chris Voronin on 11/7/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LocationUtility.h"
#import "MBProgressHUD.h"

@interface iBeaconViewControllerFullMapViewController : UIViewController <CLLocationManagerDelegate, LocationUtilityProtocol, MBProgressHUDDelegate, UIScrollViewDelegate>

@end
