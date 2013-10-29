//
//  DemoViewController.m
//  BlueToothLocator
//
//  Created by Chris Voronin on 10/1/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "DemoViewController.h"
#import "LNQue.h"
#import "GridView.h"
#import "PeripheralData.h"
#import "ActiveBeacon.h"

@interface DemoViewController ()
{
    //visible (todo... one day remove this silly code)
    UILabel * lblDebug1;
    UILabel * lblDebug2;
    UILabel * lblDebug3;
    UILabel * lblDebug4;
    UILabel * lblDebug5;
    UILabel * lblDebug6;
    UILabel * lblDebug7;
    UILabel * lblDebug8;
    UILabel * lblDebug9;
    UILabel * lblDebug10;
    UILabel * lblDebug11;
    UILabel * lblDebug12;
    
    UIImageView* imgArrow;
    GridView * grid;
    
    NSTimer * timer, *timer2;
    int connectedCount;
    int totFound;
    
    __strong NSMutableDictionary * peripheralDataDictionary;
    
    //managers
    __strong CBCentralManager * manager;
    __strong CLLocationManager * locationManager;
}
@end

@implementation DemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Location Tracking Demo";
        peripheralDataDictionary = [NSMutableDictionary dictionary];
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
    
    
    lblDebug1 = [[UILabel alloc] initWithFrame:CGRectMake(50, 250, 100, 30)];
    lblDebug1.textColor = [UIColor greenColor];
    [self.view addSubview:lblDebug1];
    
    lblDebug2 = [[UILabel alloc] initWithFrame:CGRectMake(250, 250, 100, 30)];
    lblDebug2.textColor = [UIColor greenColor];
    [self.view addSubview:lblDebug2];
    
    lblDebug3 = [[UILabel alloc] initWithFrame:CGRectMake(450, 250, 100, 30)];
    lblDebug3.textColor = [UIColor greenColor];
    [self.view addSubview:lblDebug3];
    
    lblDebug4 = [[UILabel alloc] initWithFrame:CGRectMake(650, 250, 100, 30)];
    lblDebug4.textColor = [UIColor greenColor];
    [self.view addSubview:lblDebug4];
    
    lblDebug5 = [[UILabel alloc] initWithFrame:CGRectMake(50, 350, 100, 30)];
    lblDebug5.textColor = [UIColor greenColor];
    [self.view addSubview:lblDebug5];
    
    lblDebug6 = [[UILabel alloc] initWithFrame:CGRectMake(250, 350, 100, 30)];
    lblDebug6.textColor = [UIColor greenColor];
    [self.view addSubview:lblDebug6];
    
    lblDebug7 = [[UILabel alloc] initWithFrame:CGRectMake(450, 350, 100, 30)];
    lblDebug7.textColor = [UIColor greenColor];
    [self.view addSubview:lblDebug7];
    
    lblDebug8 = [[UILabel alloc] initWithFrame:CGRectMake(650, 350, 100, 30)];
    lblDebug8.textColor = [UIColor greenColor];
    [self.view addSubview:lblDebug8];
    
    lblDebug9 = [[UILabel alloc] initWithFrame:CGRectMake(50, 450, 100, 30)];
    lblDebug9.textColor = [UIColor greenColor];
    [self.view addSubview:lblDebug9];
    
    lblDebug10 = [[UILabel alloc] initWithFrame:CGRectMake(250, 450, 100, 30)];
    lblDebug10.textColor = [UIColor greenColor];
    [self.view addSubview:lblDebug10];
    
    lblDebug11 = [[UILabel alloc] initWithFrame:CGRectMake(450, 450, 100, 30)];
    lblDebug11.textColor = [UIColor greenColor];
    [self.view addSubview:lblDebug11];
    
    lblDebug12 = [[UILabel alloc] initWithFrame:CGRectMake(650, 450, 100, 30)];
    lblDebug12.textColor = [UIColor greenColor];
    [self.view addSubview:lblDebug12];
    
    CGRect rect = self.view.frame;
    CGFloat w = self.view.frame.size.width;
    rect.size.width = rect.size.height;
    rect.size.height = w - 64; //64 = statusbar + navbar.
    
    grid = [[GridView alloc] initWithFrame:rect beaconsInRow:4 numRows:3];
    [self.view addSubview:grid];
    grid.layer.borderColor = [UIColor blueColor].CGColor;
    grid.layer.borderWidth = 1.0;
    

    UIBarButtonItem * b1 = [[UIBarButtonItem alloc] initWithTitle:@"Start" style:UIBarButtonItemStyleBordered target:self action:@selector(startIt:)];
    
    UIBarButtonItem * b2 = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStyleBordered target:self action:@selector(stopIt:)];
    
    self.navigationItem.rightBarButtonItems = @[b1, b2];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma region - CLLocationManager

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    float angle = (float)newHeading.magneticHeading;
    float angleRadians = M_PI * angle / 180.0;
    
    imgArrow.transform = CGAffineTransformMakeRotation(angleRadians);
    //newHeading.magneticHeading; -> We want this one (its in degrees). 0-360. 315-45 = north...
    //newHeading.trueHeading;
}

#pragma region - DELEGATE

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (manager.state) {
        case CBCentralManagerStateUnsupported:
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Unsupported" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            break;
        }
        case CBCentralManagerStateUnauthorized:
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Unauthorized" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            break;
        }
        case CBCentralManagerStatePoweredOff:
        {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Off" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            break;
        }
        case CBCentralManagerStatePoweredOn:
        {
            [self startScan];
        }
        default:
            break;
    }
}

-(void)startScan
{
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [manager scanForPeripheralsWithServices:nil options:options];
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //NSLog(@"Name = %@", peripheral.name);
    //NSLog(@"UUID = %@", peripheral.UUID);
    
    if (peripheral.name && !peripheral.isConnected && [peripheral.name hasPrefix:BeaconNamePrefix])
    {
        NSLog(@"Found %@", peripheral.name);
        PeripheralData *d = [[PeripheralData alloc] initWithPeripheral:peripheral];
        [peripheralDataDictionary setObject:d forKey:peripheral.name];
        
        [manager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES,
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES,
            CBConnectPeripheralOptionNotifyOnNotificationKey: @YES}];
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connectd %@", peripheral.name);
    
    peripheral.delegate = self;
    [peripheral readRSSI];
    connectedCount++;
}
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //[peripheralDataDictionary removeObjectForKey:peripheral.name];
    [manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnNotificationKey]];
    
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    connectedCount--;
    [manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnNotificationKey]];
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (error)
        return;
    
    int rssiInt = [peripheral.RSSI intValue];
    NSString * pName = peripheral.name;
    
    PeripheralData * d = [peripheralDataDictionary objectForKey:pName];
    [d.que addInt:rssiInt];
    float avg = [d.que getAverage];
    d.averageRSSI = avg;
    
    [self trilateLocation:nil];
    
    if (d.index == 1)
        lblDebug1.text = [NSString stringWithFormat:@"%f", d.distanceFromRSSI];
    else if (d.index == 2)
        lblDebug2.text = [NSString stringWithFormat:@"%f", d.distanceFromRSSI];
    else if (d.index == 3)
        lblDebug3.text = [NSString stringWithFormat:@"%f", d.distanceFromRSSI];
    else if (d.index == 4)
        lblDebug4.text = [NSString stringWithFormat:@"%f", d.distanceFromRSSI];
    else if (d.index == 5)
        lblDebug5.text = [NSString stringWithFormat:@"%f", d.distanceFromRSSI];
    else if (d.index == 6)
        lblDebug6.text = [NSString stringWithFormat:@"%f", d.distanceFromRSSI];
    else if (d.index == 7)
        lblDebug7.text = [NSString stringWithFormat:@"%f", d.distanceFromRSSI];
    else if (d.index == 8)
        lblDebug8.text = [NSString stringWithFormat:@"%f", d.distanceFromRSSI];
    else if (d.index == 9)
        lblDebug9.text = [NSString stringWithFormat:@"%f", d.distanceFromRSSI];
    else if (d.index == 10)
        lblDebug10.text = [NSString stringWithFormat:@"%f", d.distanceFromRSSI];
    else if (d.index == 11)
        lblDebug11.text = [NSString stringWithFormat:@"%f", d.distanceFromRSSI];
    else if (d.index == 12)
        lblDebug12.text = [NSString stringWithFormat:@"%f", d.distanceFromRSSI];
    
}

#pragma mark - Calculations

-(void)startIt:(id)sender
{
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager startUpdatingHeading];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(readAllRSSI:) userInfo:nil repeats:YES];
}

-(void)stopIt:(id)sender
{
    [timer invalidate];
    [manager stopScan];
    peripheralDataDictionary = [[NSMutableDictionary alloc] init];
    connectedCount = 0;
}


-(void)trilateLocation:(id)sender
{
    NSMutableArray * beacons = [NSMutableArray array];
    
    if (peripheralDataDictionary.count == 0)
    {
        [grid setBeaconsActive:beacons];
        return;
    }
    
    // otherwise sort them out.
    NSArray *sortedKeys = [self sortKeysByIntValue:peripheralDataDictionary];
    
    //NSLog(@"Sorted Begin:");
    int count = 0;
    NSLog(@"Sort Start");
    for (NSString *key in sortedKeys)
    {
        NSLog(@"Sorted %@, %f", key, ((PeripheralData*)peripheralDataDictionary[key]).averageRSSI);
        
        if (count <= 3)
        {
            PeripheralData *d = peripheralDataDictionary[key];
            if (d.peripheral.isConnected)
            {
                count++;
                
                ActiveBeacon * b = [[ActiveBeacon alloc] initWithBeaconID:d.index distance:[d distanceFromRSSI]];
            
                [beacons addObject:b];
            }
        }
        else
        {
            break;
        }
        
    }
    [grid setBeaconsActive:beacons];
}



- (NSArray *) sortKeysByIntValue:(NSDictionary *)dictionary {
    
    NSArray *sortedKeys = [dictionary keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        PeripheralData * pd1 = obj1;
        PeripheralData * pd2 = obj2;
        
        // multiply by -1 because we are negative.[p;a
        float v1 = pd1.averageRSSI * -1;
        float v2 = pd2.averageRSSI * -1;
        if (v1 < v2)
            return NSOrderedAscending;
        else if (v1 > v2)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    return sortedKeys;
}

-(void)readAllRSSI:(id)sender
{
    if (peripheralDataDictionary.count == 0)
        return;
    
    for (PeripheralData * pd in [peripheralDataDictionary allValues])
    {
        if (pd.peripheral.isConnected)
        {
            [pd.peripheral readRSSI];
        }
    }
}

@end
