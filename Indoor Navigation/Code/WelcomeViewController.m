//
//  WelcomeViewController.m
//  Indoor Navigation
//
//  Created by Chris Voronin on 11/8/13.
//  Copyright (c) 2013 Better Web Now. All rights reserved.
//

#import "WelcomeViewController.h"
#import "LoginViewController.h"
#import "HowItWorksViewController.h"
#import "SignUpViewController.h"
#import "GameViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Indoor Navigation";
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

#pragma mark - Buttons


- (IBAction)btnLoginClicked:(id)sender {
    UIViewController * vc = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btnHowItWorksClicked:(id)sender {
    UIViewController * vc = [[HowItWorksViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btnSignUpClicked:(id)sender {
    //UIViewController * vc = [[SignUpViewController alloc] init];
    //[self.navigationController pushViewController:vc animated:YES];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Contact Information" message:@"Functionality temporarily disabled. Please click the call button below to call us." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
- (IBAction)btnCallClicked:(id)sender {
    
    GameViewController * welcome = [[GameViewController alloc] init];
    [self.navigationController pushViewController:welcome animated:YES];
    return;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Contact Information" message:@"Please call 1(818)926-1116" delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:18189261116"]];
    }
}



@end
