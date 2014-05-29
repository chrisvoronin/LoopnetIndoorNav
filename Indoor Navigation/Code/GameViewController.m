//
//  GameViewController.m
//  Indoor Navigation
//
//  Created by Chris Voronin on 12/3/13.
//  Copyright (c) 2013 Better Web Now. All rights reserved.
//

#import "GameViewController.h"
#import "LNQue.h"
#import "ActiveBeacon.h"
#import "BeaconCoordinates.h"
#import "PairIntegers.h"

@interface GameViewController ()
{
    MBProgressHUD * progress;
}

@property (strong, nonatomic) CLBeaconRegion * region;
@property (strong, nonatomic) CLLocationManager * locManager;

@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"iBeacon Distance Demo";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    

    UIBarButtonItem * b1 = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleBordered target:self action:@selector(StartClicked:)];
    
    UIBarButtonItem * b2 = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStyleBordered target:self action:@selector(StopClicked:)];
    
    self.navigationItem.rightBarButtonItems = @[b1, b2];
}

- (void)initRegion {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"lopnetInoorNav"];
    if (self.region)
    {
        self.region.notifyOnEntry = YES;
        self.region.notifyOnExit = YES;
        self.region.notifyEntryStateOnDisplay = YES;
        
        if ([CLLocationManager isRangingAvailable] && [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
        {
            NSLog(@"Init Done");
            [self.locManager startRangingBeaconsInRegion:self.region];
        }
        else
        {
            NSLog(@"Failed to init");
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

#pragma mark - Beacon Ranging Main Point

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    //NSLog(@"Ranged Beacons Count = %lu", (unsigned long)beacons.count);
    
    if (beacons.count == 0)
    {
        self.lblInfo.text = @"Unknown";
        return;
    }
    
    [progress hide:YES];
    
    CLBeacon * b = beacons[0];
    
    NSLog(@"Min/Max %@ %@", b.minor, b.major);
    if (b.accuracy > 0)
        self.lblInfo.text = [NSString stringWithFormat:@"%.2f Meters", b.accuracy];
    else
        self.lblInfo.text = @"Unknown";
}

-(float)distbetweenPoints:(CGPoint)p1 p2:(CGPoint)p2
{
    return sqrt(pow(p2.x-p1.x,2) + pow(p2.y-p1.y,2));
}

#pragma mark - MBProgress

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    
}

-(void)progressTask
{
    //needs overriding
}

-(void)startTaskWithProgressTitle:(NSString*)title
{
    progress = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    progress.dimBackground = YES;
	progress.removeFromSuperViewOnHide = YES;
	progress.delegate = self;
    progress.labelText = title;
    [self.navigationController.view addSubview:progress];
    
    [progress show:YES];
}

#pragma mark - Came Near Beacon Delegate
-(void)cameNearBeaconID:(int)beaconID
{
    NSLog(@"Came near beacon %d", beaconID);
}

#pragma mark - Button Clicks


- (void)StartClicked:(id)sender {
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self initRegion];
    [self startTaskWithProgressTitle:@"Searching for a beacon..."];
}


- (void)StopClicked:(id)sender {
    [self.locManager stopRangingBeaconsInRegion:self.region];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Stopped" message:@"Ranging Stopped" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    if (progress)
    {
        [progress hide:YES];
    }
    self.lblInfo.text = @"Stopped";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
