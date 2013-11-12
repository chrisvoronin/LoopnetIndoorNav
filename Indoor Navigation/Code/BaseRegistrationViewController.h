//
//  BaseRegistrationViewController.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/27/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ValidationUtility.h"

@interface BaseRegistrationViewController : UIViewController <MBProgressHUDDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) MBProgressHUD* progress;
@property (nonatomic, strong) ValidationUtility* validation;

-(void)startTaskWithProgressTitle:(NSString*)title;

-(void)progressTask;

@end
