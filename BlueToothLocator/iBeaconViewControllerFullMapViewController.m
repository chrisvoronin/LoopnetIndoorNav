//
//  iBeaconViewControllerFullMapViewController.m
//  BlueToothLocator
//
//  Created by Chris Voronin on 11/7/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "iBeaconViewControllerFullMapViewController.h"
#import "GridViewSimple.h"
#import "LNQue.h"
#import "ActiveBeacon.h"
#import "BeaconCoordinates.h"

@interface iBeaconViewControllerFullMapViewController ()
{
    CGRect prevLocation;
    CGRect prevLocation2;
    
    UIImageView* imgArrow;
    UIImageView* squareImage;
    GridViewSimple * grid;
    UIImageView * imageFloorPlan;
    __strong NSMutableDictionary * peripheralDataDictionary;
    __strong NSMutableArray * animationQue;
    __strong LocationUtility * utility;
}

@property (strong, nonatomic) CLBeaconRegion * region;
@property (strong, nonatomic) CLLocationManager * locManager;

@end

@implementation iBeaconViewControllerFullMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"iBeacon Floorplan";
        peripheralDataDictionary = [NSMutableDictionary dictionary];
        utility = [[LocationUtility alloc] initWithMaxWidth:11.8*2.5 andMeterInPixels:11.8];
        utility.delegate = self;
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
    
    imageFloorPlan = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tourshell"]];
    [self.view addSubview:imageFloorPlan];
    
    squareImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"square"]];
    [self.view addSubview:squareImage];
    squareImage.frame = CGRectMake(0, 0, 0, 0);
    
    grid = [[GridViewSimple alloc] initWithFrame:rect];
    [self.view addSubview:grid];
    grid.layer.borderColor = [UIColor blueColor].CGColor;
    grid.layer.borderWidth = 1.0;
    
    BeaconCoordinates * bc1 = [[BeaconCoordinates alloc] initWithID:1 andCoordinate:CGPointMake(467, 143)];
    BeaconCoordinates * bc2 = [[BeaconCoordinates alloc] initWithID:2 andCoordinate:CGPointMake(526, 143)];
    BeaconCoordinates * bc3 = [[BeaconCoordinates alloc] initWithID:3 andCoordinate:CGPointMake(585, 143)];
    BeaconCoordinates * bc4 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(644, 143)];
    
    BeaconCoordinates * bc5 = [[BeaconCoordinates alloc] initWithID:5 andCoordinate:CGPointMake(467, 202)];
    BeaconCoordinates * bc6 = [[BeaconCoordinates alloc] initWithID:6 andCoordinate:CGPointMake(526, 202)];
    BeaconCoordinates * bc7 = [[BeaconCoordinates alloc] initWithID:7 andCoordinate:CGPointMake(585, 202)];
    BeaconCoordinates * bc8 = [[BeaconCoordinates alloc] initWithID:8 andCoordinate:CGPointMake(644, 202)];
    
    BeaconCoordinates * bc9 = [[BeaconCoordinates alloc] initWithID:9 andCoordinate:CGPointMake(467, 261)];
    BeaconCoordinates * bc10 = [[BeaconCoordinates alloc] initWithID:10 andCoordinate:CGPointMake(526, 261)];
    BeaconCoordinates * bc11 = [[BeaconCoordinates alloc] initWithID:11 andCoordinate:CGPointMake(585, 261)];
    BeaconCoordinates * bc12 = [[BeaconCoordinates alloc] initWithID:12 andCoordinate:CGPointMake(644, 261)];
    [grid setBeacons:@[bc1, bc2, bc3, bc4, bc5, bc6, bc7, bc8, bc9, bc10, bc11, bc12]];
    [utility setBeacons:@[bc1, bc2, bc3, bc4, bc5, bc6, bc7, bc8, bc9, bc10, bc11, bc12]];
    
    UIBarButtonItem * b1 = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleBordered target:self action:@selector(StartClicked:)];
    
    UIBarButtonItem * b2 = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStyleBordered target:self action:@selector(StopClicked:)];
    
    UIBarButtonItem * b3 = [[UIBarButtonItem alloc] initWithTitle:@"Toggle-Grid" style:UIBarButtonItemStyleBordered target:self action:@selector(ShowGrid:)];
    
    self.navigationItem.rightBarButtonItems = @[b1, b2, b3];
}

- (void)initRegion {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"lopnetInoorNav"];
    if (self.region)
    {
        self.region.notifyOnEntry = YES;
        self.region.notifyOnExit = YES;
        self.region.notifyEntryStateOnDisplay = YES;
        
        if ([CLLocationManager regionMonitoringAvailable] && [CLLocationManager isRangingAvailable] && [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]])
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

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"Ranged Beacons Count = %i", beacons.count);
    
    NSMutableArray * activeBeacons = [[NSMutableArray alloc] init];
    
    int i = 0;
    for (CLBeacon * b in beacons)
    {
        NSLog(@"%f - %@ - %@", b.accuracy, b.minor, b.major);
        if (b.accuracy > 0)
        {
            int beaconID = [b.minor intValue];
            
            // Que it up
            LNQue * que;
            if ([peripheralDataDictionary objectForKey:b.minor])
            {
                que = [peripheralDataDictionary objectForKey:b.minor];
                [que addInt:b.accuracy];
            }
            else
            {
                que = [[LNQue alloc] init];
                [que addInt:b.accuracy];
                [peripheralDataDictionary setObject:que forKey:b.minor];
            }
            float accuracy = [que getAverage];
            
            ActiveBeacon * active = [[ActiveBeacon alloc] initWithBeaconID:beaconID distance:accuracy];
            [activeBeacons addObject:active];
            i++;
            if (i == 3)
                break;
        }
    }
    
    //[grid setBeaconsActive:activeBeacons];
    CGRect rect = [utility getRectFromActiveBeacons:activeBeacons];
    
    if (prevLocation.origin.x == 0)
        prevLocation = rect;
    
    
    if (prevLocation.origin.x == rect.origin.x && prevLocation.origin.y == rect.origin.y)
    {
        squareImage.frame = rect;
    }
    prevLocation2 = prevLocation;
    prevLocation = rect;
    
    NSLog(@"RECT IS: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    //TODO: Draw that rect.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *myTouch = [[touches allObjects] objectAtIndex: 0];
    CGPoint currentPos = [myTouch locationInView: self.view];
    
    //BeaconCoordinates * bc = [[BeaconCoordinates alloc] initWithID:1 andCoordinate:currentPos];
    //[grid setBeacons:@[bc]];
    
    NSLog(@"Point in myView: (%f,%f)", currentPos.x, currentPos.y);
}

#pragma mark - Came Near Beacon Delegate
-(void)cameNearBeaconID:(int)beaconID
{
    NSLog(@"Came near beacon %d", beaconID);
}

#pragma mark - Button Clicks

-(void)ShowGrid:(id)sender
{
    [grid setHidden:!grid.isHidden];
}

- (void)StartClicked:(id)sender {
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self initRegion];
}


- (void)StopClicked:(id)sender {
    [self.locManager stopRangingBeaconsInRegion:self.region];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Stopped" message:@"Ranging Stopped" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
