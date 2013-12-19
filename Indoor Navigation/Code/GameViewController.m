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
    NSString * prevBeaconString;
    
    CGRect prevLocation;
    CGRect prevLocation2;
    UILabel * lblDebug;
    
    MBProgressHUD * progress;
    UITapGestureRecognizer *HUDSingleTap;
    
    UIImageView* imgBear;
    UIImageView* squareImage;

    UIImageView * imageFloorPlan;
    UIImageView * imageFloorPlanFull;
    __strong NSMutableDictionary * peripheralDataDictionary;
    __strong NSMutableArray * animationQue;
    __strong LocationUtility * utility;
    
    UIPinchGestureRecognizer * pinchGR;
    
    int maxBeaconDistance; // should be 7 for normal play.
}

@property (strong, nonatomic) CLBeaconRegion * region;
@property (strong, nonatomic) CLLocationManager * locManager;

@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"iBeacon Floorplan";
        peripheralDataDictionary = [NSMutableDictionary dictionary];
        utility = [[LocationUtility alloc] initWithMaxWidth:11.8*2.5 andMeterInPixels:11.8 andDelegate:self];
        animationQue = [NSMutableArray array];
        maxBeaconDistance = 14;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    CGRect rect = self.view.frame;
    CGFloat w = self.view.frame.size.width;
    rect.size.width = rect.size.height;
    rect.size.height = w - 64; //64 = statusbar + navbar.
    
    lblDebug = [[UILabel alloc] initWithFrame:CGRectMake(130, 670, 300, 20)];
    [self.view addSubview:lblDebug];
    
    imageFloorPlan = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tourshell"]];
    //[self.view addSubview:imageFloorPlan];
    
    imageFloorPlanFull = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tourfull"]];
    [imageFloorPlanFull setHidden:YES];
    //[self.view addSubview:imageFloorPlanFull];
    
    prevLocation = CGRectZero;
    prevLocation2 = CGRectZero;
    
    UIBarButtonItem * b1 = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleBordered target:self action:@selector(StartClicked:)];
    
    UIBarButtonItem * b2 = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStyleBordered target:self action:@selector(StopClicked:)];
    
    self.navigationItem.rightBarButtonItems = @[b1, b2];
    
    UIImage * imgPin = [UIImage imageNamed:@"pin"];
    squareImage = [[UIImageView alloc] initWithImage:imgPin];
    squareImage.frame = CGRectMake(rect.size.width/2, rect.size.height/2, imgPin.size.width, imgPin.size.height);
    [self.view addSubview:squareImage];
    [self.view bringSubviewToFront:squareImage];
    
    UIImage * bear = [UIImage imageNamed:@"bear"];
    imgBear = [[UIImageView alloc] initWithImage:bear];
    imgBear.frame = CGRectMake(0, 0, bear.size.width, bear.size.height);
    imgBear.hidden = YES;
    [self.view addSubview:imgBear];
    
    [self runAnimation];
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
    
    NSLog(@"Ranged Beacons Count = %lu", (unsigned long)beacons.count);
    
    if (beacons.count == 0)
        return;
    
    for (CLBeacon * b in beacons)
    {
        int beaconID = [b.minor intValue];
        if (beaconID == 5 && b.accuracy > 0 && b.accuracy < maxBeaconDistance)
        {
            [progress hide:YES];
            lblDebug.text = [NSString stringWithFormat:@"%f", b.accuracy];
            
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
            int xDist = accuracy * 40;
            int xPoint = squareImage.frame.origin.x + xDist;
            int yPoint = squareImage.frame.origin.y;
            CGRect bearFrame = imgBear.frame;
            bearFrame.origin = CGPointMake(xPoint, yPoint);
            
            PairIntegers * pi = [[PairIntegers alloc] init];
            pi.pt = bearFrame;
            
            @synchronized(animationQue)
            {
                if (animationQue.count == 0)
                {
                    CGPoint last = imgBear.frame.origin;
                    float dist = [self distbetweenPoints:last p2:pi.pt.origin];
                    if (dist > 10)
                    {
                        NSLog(@"No animations, adding %f", dist);
                        [animationQue addObject:pi];
                    }
                }
                else
                {
                    CGRect last = ((PairIntegers*)[animationQue lastObject]).pt;
                    float dist = [self distbetweenPoints:last.origin p2:pi.pt.origin];
                    if (dist < 10)
                    {
                        NSLog(@"Same no need to add");
                    }
                    else
                    {
                        NSLog(@"Adding animation %f", dist);
                        [animationQue addObject:pi];
                    }
                }
            }
            
            //[imgBear setFrame:bearFrame];
        }
    }
}

-(float)distbetweenPoints:(CGPoint)p1 p2:(CGPoint)p2
{
    return sqrt(pow(p2.x-p1.x,2) + pow(p2.y-p1.y,2));
}

-(void)runAnimation
{
    CGRect next = CGRectZero;
    
    //NSLog(@"Running animation");
    
    @synchronized(animationQue)
    {
        if (animationQue.count > 0)
        {
            next = ((PairIntegers*)animationQue[0]).pt;
            [animationQue removeObjectAtIndex:0];
        }
    }
    if (next.origin.x > 0)
    {
        [UIView animateWithDuration:0.5 animations:^{
            imgBear.frame = next;
            [imgBear setHidden:NO];
        } completion:^(BOOL finished) {
            [self performSelector:@selector(runAnimation) withObject:nil afterDelay:1.0];
            
        }];
    }
    else
    {
        [self performSelector:@selector(runAnimation) withObject:nil afterDelay:1.0];
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *myTouch = [[touches allObjects] objectAtIndex: 0];
    CGPoint currentPos = [myTouch locationInView: self.view];
    
    //BeaconCoordinates * bc = [[BeaconCoordinates alloc] initWithID:1 andCoordinate:currentPos];
    //[grid setBeacons:@[bc]];
    
    NSLog(@"Point in myView: (%f,%f)", currentPos.x, currentPos.y);
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
    
    HUDSingleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [progress addGestureRecognizer:HUDSingleTap];
    
    [progress show:YES];
}

-(void)singleTap:(UITapGestureRecognizer*)sender
{
    [self StopClicked:nil];
}

#pragma mark - Came Near Beacon Delegate
-(void)cameNearBeaconID:(int)beaconID
{
    NSLog(@"Came near beacon %d", beaconID);
}

#pragma mark - Button Clicks

-(void)ShowPlan:(id)sender
{
    [imageFloorPlanFull setHidden:!imageFloorPlanFull.hidden];
}


- (void)StartClicked:(id)sender {
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self initRegion];
    [self startTaskWithProgressTitle:@"Triangulating your location..."];
}


- (void)StopClicked:(id)sender {
    [self.locManager stopRangingBeaconsInRegion:self.region];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Stopped" message:@"Ranging Stopped" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    if (progress)
    {
        [progress hide:YES];
    }
    squareImage.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
