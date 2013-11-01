//
//  iBeaconViewController.m
//  BlueToothLocator
//
//  Created by Chris Voronin on 11/1/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "iBeaconViewController.h"
#import "GridView.h"
#import "ActiveBeacon.h"

@interface iBeaconViewController ()
{
    UIImageView* imgArrow;
    GridView * grid;
}

@property (strong, nonatomic) CLBeaconRegion * region;
@property (strong, nonatomic) CLLocationManager * locManager;

@end

@implementation iBeaconViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"iBeacon";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.borderWidth = 1;
    self.view.layer.borderColor = [UIColor greenColor].CGColor;
    
    imgArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-right.jpg"]];
    imgArrow.frame = CGRectMake(30, 670, 20, 20);
    [self.view addSubview:imgArrow];
    
    CGRect rect = self.view.frame;
    CGFloat w = self.view.frame.size.width;
    rect.size.width = rect.size.height;
    rect.size.height = w - 64; //64 = statusbar + navbar.
    
    grid = [[GridView alloc] initWithFrame:rect beaconsInRow:4 numRows:3];
    [self.view addSubview:grid];
    grid.layer.borderColor = [UIColor blueColor].CGColor;
    grid.layer.borderWidth = 1.0;
    
    
    UIBarButtonItem * b1 = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleBordered target:self action:@selector(StartClicked:)];
    
    UIBarButtonItem * b2 = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStyleBordered target:self action:@selector(StopClicked:)];
    
    self.navigationItem.rightBarButtonItems = @[b1, b2];
}

- (IBAction)StartClicked:(id)sender {
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self initRegion];
    // not sure
    //[self locationManager:self.locManager didStartMonitoringForRegion:self.region];
}

- (void)initRegion {
    //E2C56DB5-DFFB-48D2-B060-D0F5A71096E0
    //83256B74-78D0-43A4-8269-05F0DC8A44BA
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"lopnetInoorNav"];
    if (self.region)
    {
        self.region.notifyOnEntry = YES;
        self.region.notifyOnExit = YES;
        self.region.notifyEntryStateOnDisplay = YES;
        NSLog(@"Inited");
        NSLog(@"region mon avail %i", [CLLocationManager regionMonitoringAvailable]);
        NSLog(@"ranging avail %i", [CLLocationManager isRangingAvailable]);
        NSLog(@"class avail %i", [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]);
    
        if ([CLLocationManager regionMonitoringAvailable] && [CLLocationManager isRangingAvailable] && [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
        {
            NSLog(@"Enabled");
            //[self.locManager startMonitoringForRegion:self.region];
            [self.locManager startRangingBeaconsInRegion:self.region];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locManager startRangingBeaconsInRegion:self.region];
    NSLog(@"Started Monitoring");
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Entered Region");
    [self.locManager startRangingBeaconsInRegion:self.region];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Region monitoring failed with error: %@", [error localizedDescription]);
}
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Region monitoring failed with error: %@", [error localizedDescription]);
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Exited Region");
    
    [self.locManager stopRangingBeaconsInRegion:self.region];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"Ranged Beacons Count = %i", beacons.count);
    
    NSMutableArray * activeBeacons = [[NSMutableArray alloc] init];
    
    //TODO: Investigate if we need need to sort this or it's presorted.
    // this is without storing beacon references and prior values.
    // that may change.
    NSArray *sortedArray;
    sortedArray = [beacons sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        double first = [(CLBeacon*)a accuracy];
        double second = [(CLBeacon*)b accuracy];
        if (first < second)
            return NSOrderedAscending;
        else if (first > second)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    
    for (CLBeacon * b in sortedArray)
    {
        int beaconID = [b.minor intValue];
        ActiveBeacon * active = [[ActiveBeacon alloc] initWithBeaconID:beaconID distance:b.accuracy];
        [activeBeacons addObject:active];
    }
    
    [grid setBeaconsActive:activeBeacons];
}


- (IBAction)StopClicked:(id)sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 //    self.lblUUID.text = @"Yes";
 //    self.lblAccuracy.text = [NSString stringWithFormat:@"%f", beacon.accuracy];
 //    if (beacon.proximity == CLProximityUnknown) {
 //        self.lblDistance.text = @"Unknown Proximity";
 //    } else if (beacon.proximity == CLProximityImmediate) {
 //        self.lblDistance.text = @"Immediate";
 //    } else if (beacon.proximity == CLProximityNear) {
 //        self.lblDistance.text = @"Near";
 //    } else if (beacon.proximity == CLProximityFar) {
 //        self.lblDistance.text = @"Far";
 //    }
 //    self.lblRSSI.text = [NSString stringWithFormat:@"%i", beacon.rssi];
 */

@end
