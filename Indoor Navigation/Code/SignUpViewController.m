//
//  SignUpViewController.m
//  Indoor Navigation
//
//  Created by Chris Voronin on 11/8/13.
//  Copyright (c) 2013 Better Web Now. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()
@property (strong, nonatomic) IBOutlet UITextField *txtFullName;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtConfirmPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtPhoneNumber;

@end

@implementation SignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Register";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtFullName andValidationType:ValidationEmpty]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtEmail andValidationType:ValidationEmail]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtPhoneNumber andValidationType:ValidationPhone]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtPassword andValidationType:ValidationMinLength andLength:6]];
    [self.validation addValidationModel: [[ValidationModel alloc] initWithField:self.txtConfirmPassword mustMatch:self.txtPassword]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtFullName)
    {
        [self.txtEmail becomeFirstResponder];
    }
    else if (textField == self.txtEmail)
    {
        [self.txtPassword becomeFirstResponder];
    }
    else if (textField == self.txtPassword)
    {
        [self.txtConfirmPassword becomeFirstResponder];
    }
    else if (textField == self.txtConfirmPassword)
    {
        [self.txtPhoneNumber becomeFirstResponder];
    }
    else if (textField == self.txtPhoneNumber)
    {
        [self btnRegisterClicked:nil];
    }
    
    return NO;
}


- (IBAction)btnRegisterClicked:(id)sender {
    BOOL isValid = [self.validation validateFormAndShowAlert:YES];
    
    if (isValid)
    {
        [self.progress showWhileExecuting:@selector(progressTask) onTarget:self withObject:nil animated:YES];
    }
}

-(void)progressTask
{
    //TODO: service call
    sleep(3);
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Thank You!" message:@"Your information has been sent. Someone will contact you shortly." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
