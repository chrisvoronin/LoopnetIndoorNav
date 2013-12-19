//
//  GameViewController.h
//  Indoor Navigation
//
//  Created by Chris Voronin on 12/3/13.
//  Copyright (c) 2013 Better Web Now. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LocationUtility.h"

@interface GameViewController : UIViewController <CLLocationManagerDelegate, MBProgressHUDDelegate, LocationUtilityProtocol>

@end
