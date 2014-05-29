//
//  MagnoMeterViewController.m
//  Indoor Navigation
//
//  Created by Chris Voronin on 12/23/13.
//  Copyright (c) 2013 Better Web Now. All rights reserved.
//

#import "MagnoMeterViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>

@interface MagnoMeterViewController ()
{
    CMMotionManager * motionManager;
    CLLocationManager * locationManager;
    __strong NSMutableArray * values;
}
@end

@implementation MagnoMeterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}

-(void)StartClicked:(id)sender
{
    return;
    
    // Getting Elevation Value
    CMDeviceMotionHandler  motionHandler = ^ (CMDeviceMotion *motion, NSError *error) {
        //CMAttitude *a = motionManager.deviceMotion.attitude;
        CMMagneticField field = motion.magneticField.field;
        
        
        NSString * value = [[NSString stringWithFormat:@"%.1f", sqrt(field.x*field.x + field.y*field.y + field.z*field.z)] stringByAppendingFormat:@" µT"];
        
        NSString * headingInfo = [NSString stringWithFormat:@"Magnetic value: %@, %d", value, motion.magneticField.accuracy];
        
        [values addObject:headingInfo];
        [self.tableView reloadData];
        // scroll to bottom
        CGFloat yOffset = 0;
        
        if (self.tableView.contentSize.height > self.tableView.bounds.size.height) {
            yOffset = self.tableView.contentSize.height - self.tableView.bounds.size.height;
        }
        
        [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
        
        //NSLog(@"Elevation value, %@:", [[NSString stringWithFormat:@"%.0f", a.pitch*180/M_PI] stringByAppendingFormat:@"˚"]);
    };
    [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical toQueue:[NSOperationQueue currentQueue] withHandler:motionHandler];
    
    
    
    [motionManager startMagnetometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
        
        if (error)
        {
            NSLog(@"%@", error.localizedDescription);
            return;
        }
        
        CMMagneticField mf = magnetometerData.magneticField;
        double magnitude = sqrt(mf.x * mf.x + mf.y * mf.y + mf.z * mf.z);
        
        [values addObject:[NSString stringWithFormat:@"%.2f", magnitude]];
        [self.tableView reloadData];
        
        // scroll to bottom
        CGFloat yOffset = 0;
        
        if (self.tableView.contentSize.height > self.tableView.bounds.size.height) {
            yOffset = self.tableView.contentSize.height - self.tableView.bounds.size.height;
        }
        
        [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
        
    }];
}

-(void)StopClicked:(id)sender
{
    [motionManager stopMagnetometerUpdates];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem * b1 = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleBordered target:self action:@selector(StartClicked:)];
    
    UIBarButtonItem * b2 = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStyleBordered target:self action:@selector(StopClicked:)];
    
    self.navigationItem.rightBarButtonItems = @[b1, b2];
    
    values = [NSMutableArray array];
    
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = 1.f/1.f;
    motionManager.magnetometerUpdateInterval = 1.f/1.f;
    motionManager.showsDeviceMovementDisplay = YES;
    
    // Starting compass setup
    if(locationManager == nil)
        locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    
    //Start the compass updates.
    if (CLLocationManager.headingAvailable) {
        [locationManager startUpdatingHeading];
        [locationManager startUpdatingLocation];
    }
    else {
        NSLog(@"No Heading Available: ");
        UIAlertView *noCompassAlert = [[UIAlertView alloc] initWithTitle:@"No Compass!" message:@"This device does not have the ability to measure magnetic fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noCompassAlert show];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return values.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    NSString * value = values[indexPath.row];
    cell.textLabel.text = value;
    return cell;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //return;
    
    CLLocation * loc = [locations lastObject];
    NSString * value = [NSString stringWithFormat:@"Speed-Course = %f, %f", loc.speed, loc.course];
    [values addObject:value];
    [self.tableView reloadData];
    // scroll to bottom
    CGFloat yOffset = 0;
    
    if (self.tableView.contentSize.height > self.tableView.bounds.size.height) {
        yOffset = self.tableView.contentSize.height - self.tableView.bounds.size.height;
    }
    
    [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
    
}

-(void)locationManager:(CLLocationManager *) manager didUpdateHeading:(CLHeading *)newHeading
{
    
    return;
    
    NSString * value = [[NSString stringWithFormat:@"%.1f", sqrt(newHeading.x*newHeading.x + newHeading.y*newHeading.y + newHeading.z*newHeading.z)] stringByAppendingFormat:@" µT"];
    
    NSString * headingInfo = [NSString stringWithFormat:@"Magnetic value: %@", value];
    
    [values addObject:headingInfo];
    [self.tableView reloadData];
    // scroll to bottom
    CGFloat yOffset = 0;
    
    if (self.tableView.contentSize.height > self.tableView.bounds.size.height) {
        yOffset = self.tableView.contentSize.height - self.tableView.bounds.size.height;
    }
    
    [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
}

@end
