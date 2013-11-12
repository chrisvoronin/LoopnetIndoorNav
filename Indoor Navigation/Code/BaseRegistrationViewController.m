//
//  BaseRegistrationViewController.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/27/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "BaseRegistrationViewController.h"

@interface BaseRegistrationViewController ()
{
    UITapGestureRecognizer * tapGR;
}
@end

@implementation BaseRegistrationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.validation = [[ValidationUtility alloc] initWithAlertMessage:@"Please fill out all required fields" andTitle:@"Error" andValidColor:[UIColor whiteColor] andNotValidColor:[UIColor yellowColor]];
    
    tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tapGR.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGR];
}



-(void)startTaskWithProgressTitle:(NSString*)title
{
    self.progress = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    self.progress.dimBackground = YES;
	self.progress.removeFromSuperViewOnHide = YES;
	self.progress.delegate = self;
    self.progress.labelText = title;
    [self.navigationController.view addSubview:self.progress];
    
    [self.progress showWhileExecuting:@selector(progressTask) onTarget:self withObject:nil animated:YES];
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.progress.delegate = nil;
    [self.progress removeFromSuperview];
    self.progress = nil;
    [super viewWillDisappear:animated];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Smart Swipe" message:@"Base Controller Alert" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

-(void)hideKeyboard
{
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

-(void)progressTask
{
    //needs overriding
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}

- (void) animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = 60; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)appEnteredBackground{
    [self hideKeyboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
