//
//  LoginViewController.m
//  Indoor Navigation
//
//  Created by Chris Voronin on 11/8/13.
//  Copyright (c) 2013 Better Web Now. All rights reserved.
//

#import "LoginViewController.h"
#import "iBeaconViewControllerFullMapViewController.h"

@interface LoginViewController ()
{
    bool isLoggedOn;
    NSArray * listSteps;
}
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Login";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtPassword andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtEmail andValidationType:ValidationEmail]];
    
    //self.txtEmail.text = @"andy@loopnet.com";
    //self.txtPassword.text = @"2747";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnLoginClicked:(id)sender {
    BOOL isValid = [self.validation validateFormAndShowAlert:YES];
    
    if (isValid)
    {
        self.progress = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.progress];
        self.progress.dimBackground = YES;
        self.progress.labelText = @"Authenticating...";
        
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        self.progress.delegate = self;
        [self.progress showWhileExecuting:@selector(progressTask) onTarget:self withObject:nil animated:YES];
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtEmail)
    {
        [self.txtPassword becomeFirstResponder];
    }
    else if (textField == self.txtPassword)
    {
        [self btnLoginClicked:nil];
    }
    
    return NO;
}

-(void)progressTask
{
    sleep(2);
    
    if ([self.txtEmail.text hasSuffix:@"@loopnet.com"] && [self.txtPassword.text isEqualToString:@"2747"])
    {
        isLoggedOn = true;
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (!isLoggedOn)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Invalid Login!" message:@"Please check your information and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        iBeaconViewControllerFullMapViewController * vc = [[iBeaconViewControllerFullMapViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
