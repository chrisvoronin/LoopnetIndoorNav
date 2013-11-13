//
//  HowItWorksViewController.m
//  Indoor Navigation
//
//  Created by Chris Voronin on 11/8/13.
//  Copyright (c) 2013 Better Web Now. All rights reserved.
//

#import "HowItWorksViewController.h"


@interface HowItWorksViewController ()
{
    __strong NSMutableArray * photos;
}
@end

@implementation HowItWorksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"How it works";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnDemoClicked:(id)sender {
    // Create array of `MWPhoto` objects
    photos = [NSMutableArray array];
    [photos addObject:[MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"floorPlan" ofType:@"png"]]]];
    [photos addObject:[MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"floorPlan2" ofType:@"jpg"]]]];
    ((MWPhoto*)[photos objectAtIndex:0]).caption = @"Mall of the World";
    // Create & present browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    // Set options
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = YES; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    // Present
    [self.navigationController pushViewController:browser animated:YES];
    
    // Manipulate!
    [browser showPreviousPhotoAnimated:YES];
    [browser showNextPhotoAnimated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < photos.count)
        return [photos objectAtIndex:index];
    return nil;
}

@end
