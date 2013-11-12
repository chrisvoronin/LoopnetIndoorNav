//
//  ValidationUtility.h
//  SmartSwipe
//
//  Created by Chris Voronin on 10/27/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ValidationModel.h"

@interface ValidationUtility : NSObject

@property (nonatomic, copy) NSString * alertMessage;
@property (nonatomic, copy) NSString * alertTitle;
@property (nonatomic, copy) UIColor * colorValid;
@property (nonatomic, copy) UIColor * colorNotValid;

-(id)initWithAlertMessage:(NSString*)message andTitle:(NSString*)title andValidColor:(UIColor*)valid andNotValidColor:(UIColor*)invalid;

-(void)addValidationModel:(ValidationModel*)model;

-(BOOL)validateFormAndShowAlert:(BOOL)showAlert;

@end
