//
//  SelectViewController.m
//  BlueToothLocator
//
//  Created by Chris Voronin on 11/1/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "SelectViewController.h"
#import "DemoViewController.h"
#import "iBeaconViewController.h"
#import "iBeaconViewControllerFullMapViewController.h"

@interface SelectViewController ()

@end

@implementation SelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Home";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)iBeaconOption:(id)sender {
    iBeaconViewController * home = [[iBeaconViewController alloc] init];
    [self.navigationController pushViewController:home animated:YES];
}
- (IBAction)simpleOption:(id)sender {
    DemoViewController * home = [[DemoViewController alloc] init];
    [self.navigationController pushViewController:home animated:YES];
}
- (IBAction)floorPlanOption:(id)sender {
    
    iBeaconViewControllerFullMapViewController * home = [[iBeaconViewControllerFullMapViewController alloc] init];
    [self.navigationController pushViewController:home animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
