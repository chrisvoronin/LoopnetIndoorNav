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
#import "PairIntegers.h"

@interface iBeaconViewControllerFullMapViewController ()
{
    NSString * prevBeaconString;
    
    CGRect prevLocation;
    CGRect prevLocation2;
    UILabel * lblDebug;
    
    MBProgressHUD * progress;
    UITapGestureRecognizer *HUDSingleTap;
    
    UIImageView* imgArrow;
    UIImageView* squareImage;
    GridViewSimple * grid;
    UIImageView * imageFloorPlan;
    UIImageView * imageFloorPlanFull;
    __strong NSMutableDictionary * peripheralDataDictionary;
    __strong NSMutableArray * animationQue;
    __strong LocationUtility * utility;
    
    UIPinchGestureRecognizer * pinchGR;
    
    UIScrollView * scrollView;
    UIView *containerView;
    
    int maxBeaconDistance; // should be 7 for normal play.
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
    
    CGRect frame = rect;
    // create scroll view.
    scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.delegate = self;
    scrollView.scrollEnabled = YES;
    [self.view addSubview:scrollView];
    
    // add container view.
    containerView = [[UIView alloc] initWithFrame:frame];
    [scrollView addSubview:containerView];
    
    scrollView.contentSize = frame.size;
    
    imgArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"largearrowup"]];
    imgArrow.frame = CGRectMake(30, 670, 20, 20);
    [containerView addSubview:imgArrow];
    
    lblDebug = [[UILabel alloc] initWithFrame:CGRectMake(130, 670, 300, 20)];
    [containerView addSubview:lblDebug];
    
    imageFloorPlan = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tourshell"]];
    [containerView addSubview:imageFloorPlan];
    
    imageFloorPlanFull = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tourfull"]];
    [imageFloorPlanFull setHidden:YES];
    [containerView addSubview:imageFloorPlanFull];
    
    grid = [[GridViewSimple alloc] initWithFrame:rect];
    [containerView addSubview:grid];
    grid.layer.borderColor = [UIColor blueColor].CGColor;
    grid.layer.borderWidth = 1.0;
    
    
    
    prevLocation = CGRectZero;
    prevLocation2 = CGRectZero;
    
    BeaconCoordinates * bc1 = [[BeaconCoordinates alloc] initWithID:1 andCoordinate:CGPointMake(467, 143)];
    BeaconCoordinates * bc2 = [[BeaconCoordinates alloc] initWithID:2 andCoordinate:CGPointMake(526, 143)];
    BeaconCoordinates * bc3 = [[BeaconCoordinates alloc] initWithID:3 andCoordinate:CGPointMake(585, 143)];
    BeaconCoordinates * bc4 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(644, 143)];
    BeaconCoordinates * bc42 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(703, 143)];
    BeaconCoordinates * bc43 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(762, 143)];
    BeaconCoordinates * bc44 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(821, 143)];
    BeaconCoordinates * bc45 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(880, 143)];
    BeaconCoordinates * bc46 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(939, 143)];
    
    BeaconCoordinates * bc5 = [[BeaconCoordinates alloc] initWithID:5 andCoordinate:CGPointMake(467, 202)];
    BeaconCoordinates * bc6 = [[BeaconCoordinates alloc] initWithID:6 andCoordinate:CGPointMake(526, 202)];
    BeaconCoordinates * bc7 = [[BeaconCoordinates alloc] initWithID:7 andCoordinate:CGPointMake(585, 202)];
    BeaconCoordinates * bc8 = [[BeaconCoordinates alloc] initWithID:8 andCoordinate:CGPointMake(644, 202)];
    BeaconCoordinates * bc52 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(703, 202)];
    BeaconCoordinates * bc53 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(762, 202)];
    BeaconCoordinates * bc54 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(821, 202)];
    BeaconCoordinates * bc55 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(880, 202)];
    BeaconCoordinates * bc56 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(939, 202)];
    
    BeaconCoordinates * bc9 = [[BeaconCoordinates alloc] initWithID:9 andCoordinate:CGPointMake(467, 261)];
    BeaconCoordinates * bc10 = [[BeaconCoordinates alloc] initWithID:10 andCoordinate:CGPointMake(526, 261)];
    BeaconCoordinates * bc11 = [[BeaconCoordinates alloc] initWithID:11 andCoordinate:CGPointMake(585, 261)];
    BeaconCoordinates * bc12 = [[BeaconCoordinates alloc] initWithID:12 andCoordinate:CGPointMake(644, 261)];
    BeaconCoordinates * bc62 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(703, 261)];
    BeaconCoordinates * bc63 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(762, 261)];
    BeaconCoordinates * bc64 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(821, 261)];
    BeaconCoordinates * bc65 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(880, 261)];
    BeaconCoordinates * bc66 = [[BeaconCoordinates alloc] initWithID:4 andCoordinate:CGPointMake(939, 261)];
    
    [grid setBeacons:@[bc1, bc2, bc3, bc4, bc42, bc43, bc44, bc45, bc46, bc52, bc53, bc54, bc55, bc56, bc62, bc63, bc64, bc65, bc66, bc5, bc6, bc7, bc8, bc9, bc10, bc11, bc12]];
    [utility setBeacons:@[bc1, bc2, bc3, bc4, bc42, bc43, bc44, bc45, bc46, bc52, bc53, bc54, bc55, bc56, bc62, bc63, bc64, bc65, bc66, bc5, bc6, bc7, bc8, bc9, bc10, bc11, bc12]];
    
    UIBarButtonItem * b1 = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleBordered target:self action:@selector(StartClicked:)];
    
    UIBarButtonItem * b2 = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStyleBordered target:self action:@selector(StopClicked:)];
    
    UIBarButtonItem * b3 = [[UIBarButtonItem alloc] initWithTitle:@"ToggleGrid" style:UIBarButtonItemStyleBordered target:self action:@selector(ShowGrid:)];
    
    UIBarButtonItem * b4 = [[UIBarButtonItem alloc] initWithTitle:@"ToggleLayout" style:UIBarButtonItemStyleBordered target:self action:@selector(ShowPlan:)];
    
    self.navigationItem.rightBarButtonItems = @[b1, b2, b3, b4];
    
    UIImage * imgPin = [UIImage imageNamed:@"pin"];
    squareImage = [[UIImageView alloc] initWithImage:imgPin];
    squareImage.frame = CGRectMake(50, 50, imgPin.size.width, imgPin.size.height);
    [containerView addSubview:squareImage];
    [containerView bringSubviewToFront:squareImage];
    squareImage.hidden = YES;
    
    pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    //[self.view addGestureRecognizer:pinchGR];
    
    [self runAnimation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set up the minimum & maximum zoom scales
    CGRect scrollViewFrame = scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    
    scrollView.minimumZoomScale = minScale;
    scrollView.maximumZoomScale = 3.0f;
    scrollView.zoomScale = minScale;
    
    [self centerScrollViewContents];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    scrollView = nil;
    containerView = nil;
}

-(void)pinchAction:(UIPinchGestureRecognizer*)recognizer
{
    if (recognizer.scale > 1.0f && recognizer.scale < 2.5f)
    {
        CGAffineTransform transo = CGAffineTransformMakeScale(recognizer.scale, recognizer.scale);
        self.view.transform = transo;
    }
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
    
    NSMutableArray * activeBeacons = [[NSMutableArray alloc] init];
    
    int i = 0;
    for (CLBeacon * b in beacons)
    {
        if (i == 0)
            lblDebug.text = [NSString stringWithFormat:@"%f - %@", b.accuracy, b.minor];
        
        if (b.accuracy > 0  && b.accuracy < maxBeaconDistance)
        {
            NSLog(@"%f - %@", b.accuracy, b.minor);
            
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
    
    // return if 0.
    if (activeBeacons.count == 0)
        return;
    
    /*new stuff*/
    
    NSString * beaconString = @"";
    int countBeacons = MIN((int)activeBeacons.count, 3);
    for (int i = 0; i < countBeacons; i++)
    {
        ActiveBeacon * b = activeBeacons[i];
        beaconString = [NSString stringWithFormat:@"%@,%d", beaconString, b.beaconID];
    }
    if ([prevBeaconString isEqualToString:beaconString])
    {
        CGRect currFrame = squareImage.frame;
        CGRect rect = [utility getRectFromActiveBeacons:activeBeacons];
        CGPoint ptCenter;
        ptCenter.x = rect.origin.x + rect.size.width / 2;
        ptCenter.y = rect.origin.y + rect.size.height / 2;
        ptCenter.x -= currFrame.size.width;
        ptCenter.y -= currFrame.size.height;
        currFrame.origin = ptCenter;
        if (squareImage.hidden)
        {
            squareImage.hidden = NO;
            squareImage.frame = currFrame;
            [progress hide:YES];
        }
        else
        {
            PairIntegers * pi = [[PairIntegers alloc] init];
            pi.pt = currFrame;
            
            @synchronized(animationQue)
            {
                if (animationQue.count == 0)
                {
                    CGPoint last = squareImage.frame.origin;
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
        }
        // clear it so we can read it in twice again.
        prevBeaconString = @"";
    }
    else
    {
        prevBeaconString = beaconString;
    }
    
    
    return;
     /*new stuff end*/
    
    CGRect rect = [utility getRectFromActiveBeacons:activeBeacons];
    
    if (prevLocation.origin.x == 0)
    {
        prevLocation = rect;
        prevLocation2 = rect;
    }
    
    //to avoid unnecessary jumps, lets get 2 similar in a row.
    if (CGRectIntersectsRect(prevLocation, rect) && rect.origin.x > 0)
    {
        if (progress)
        {
            [progress hide:YES];
        }
        squareImage.hidden = NO;
        CGRect frm = squareImage.frame;
        frm.origin = rect.origin;
        frm.origin.x -= frm.size.width / 2;
        frm.origin.y -= frm.size.height;
        squareImage.frame = frm;
    }
    prevLocation2 = prevLocation;
    prevLocation = rect;
    
    
    //NSLog(@"RECT IS: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
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
            squareImage.frame = next;
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

-(void)ShowGrid:(id)sender
{
    [grid setHidden:!grid.isHidden];
}

- (void)StartClicked:(id)sender {
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self initRegion];
    [self startTaskWithProgressTitle:@"Triangulating your location..."];
    [self.locManager startUpdatingHeading];
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

#pragma mark - UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

#pragma mark - Scrolling

- (void)centerScrollViewContents {
    CGSize boundsSize = scrollView.bounds.size;
    CGRect contentsFrame = containerView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    containerView.frame = contentsFrame;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    
    theHeading += 90.0f;
    
    float headingDegrees = (theHeading*M_PI/180); //assuming needle points to top of iphone. convert to radians
    imgArrow.transform = CGAffineTransformMakeRotation(headingDegrees);
}

-(BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}

@end
