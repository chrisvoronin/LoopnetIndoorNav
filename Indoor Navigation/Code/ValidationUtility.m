//
//  ValidationUtility.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/27/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "ValidationUtility.h"

@interface ValidationUtility ()

@property (nonatomic, strong) NSMutableArray * validationList;

@end

@implementation ValidationUtility

-(id)initWithAlertMessage:(NSString*)message andTitle:(NSString*)title andValidColor:(UIColor*)valid andNotValidColor:(UIColor*)invalid
{
    self = [super init];
    if (self)
    {
        self.alertMessage = message;
        self.alertTitle = title;
        self.colorValid = valid;
        self.colorNotValid = invalid;
        self.validationList = [NSMutableArray array];
    }
    return self;
}


-(void)addValidationModel:(ValidationModel*)model
{
    [self.validationList addObject:model];
}


-(BOOL)validateFormAndShowAlert:(BOOL)showAlert
{
    BOOL isValid = YES;
    NSString * text;
    for (ValidationModel * m in self.validationList)
    {
        BOOL isHidden = [self isFieldHidden:m.field];
        BOOL fieldValid = YES;
        if (!isHidden)
        {
            text = [self getTextFromView:m.field];
            
            switch (m.validationType) {
                case ValidationEmail:
                    fieldValid = [self validateEmail:text];
                    break;
                case ValidationABA:
                    fieldValid = [self validateRoutingNumber:text];
                    break;
                case ValidationEmpty:
                    fieldValid = [self validateEmpty:text];
                    break;
                case ValidationNumbersOnly:
                    fieldValid = [self validateNumbersOnly:text];
                    break;
                case ValidationZipCode:
                    fieldValid = [self validateZipCode:text];
                    break;
                case ValidationFullName:
                    fieldValid = [self validateFullName:text];
                    break;
                case ValidationMinLength:
                    fieldValid = [self validateMinLength:text length:m.length];
                    break;
                case ValidationExactLength:
                    fieldValid = [self validateLength:text length:m.length];
                    break;
                case ValidationMustMatch:
                {
                    NSString * textMatch = [self getTextFromView:m.fieldMatch];
                    fieldValid = [self validateMatch:text andMatch:textMatch];
                    break;
                }
                case ValidationPhone:
                    fieldValid = [self validatePhone:text];
                    break;
                default:
                    break;
            }
        }
        if (fieldValid)
        {
            [self setField:m.field backgroundColor:self.colorValid];
        }
        else
        {
            isValid = NO;
            [self setField:m.field backgroundColor:self.colorNotValid];
        }
    }
    
    if (!isValid && showAlert)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:self.alertTitle message:self.alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
    return isValid;
}

#pragma mark - internal private methods

-(void)setField:(id<UITextInput>)input backgroundColor:(UIColor*)color
{
    if ([input isKindOfClass:[UITextField class]])
    {
        ((UITextField*)input).backgroundColor = color;
    }
    else if ([input isKindOfClass:[UITextView class]])
    {
        ((UITextView*)input).backgroundColor = color;
    }
}

-(NSString*)getTextFromView:(id<UITextInput>)input
{
    if ([input isKindOfClass:[UITextField class]])
    {
        return ((UITextField*)input).text;
    }
    else if ([input isKindOfClass:[UITextView class]])
    {
        return ((UITextView*)input).text;
    }
    return @"";
}

-(BOOL)isFieldHidden:(id<UITextInput>)input
{
    if ([input isKindOfClass:[UITextField class]])
    {
        return ((UITextField*)input).isHidden;
    }
    else if ([input isKindOfClass:[UITextView class]])
    {
        return ((UITextView*)input).isHidden;
    }
    return NO;
}

#pragma mark - Generic Validation

-(BOOL)validateEmail:(NSString*)text
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:text];
}

-(BOOL)validateEmpty:(NSString*)text
{
    text = [self trimSpaces:text];
    
    if(text.length > 1)
    {
        return YES;
    }
    return NO;
}

-(BOOL)validateNumbersOnly:(NSString*)text
{
    NSCharacterSet* numberCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [text length]; ++i)
    {
        unichar c = [text characterAtIndex:i];
        if (![numberCharSet characterIsMember:c])
        {
            return NO;
        }
    }
    return YES;
}

-(BOOL)validateLength:(NSString*)text length:(int)length
{
    if (text.length == length)
        return YES;
    else
        return NO;
}

-(BOOL)validateMinLength:(NSString*)text length:(int)length
{
    return text.length >= length;
}

-(BOOL)validateRoutingNumber:(NSString*)text
{
    text = [self trimSpaces:text];
    
    if (text.length != 9)
        return NO;
    
    int sum = 0;
    for (int i = 0; i < 9; i++)
    {
        int val = [[text substringWithRange:NSMakeRange(i, 1)] intValue];
        if (i == 0 || i == 3 || i == 6)
            sum += val * 3;
        else if (i == 1 || i == 4 || i == 7)
            sum += val * 7;
        else
            sum += val;
    }
    
    if (sum % 10 == 0)
        return YES;
    else
        return NO;
}

-(BOOL)validateZipCode:(NSString*)text
{
    if ([self validateLength:text length:5] && [self validateNumbersOnly:text])
        return YES;
    return NO;
}

-(BOOL)validateFullName:(NSString*)text
{
    text = [self trimSpaces:text];
    
    NSArray* parts = [text componentsSeparatedByString:@" "];
    return parts.count > 1 && text.length > 7;
}

-(BOOL)validateMatch:(NSString*)text andMatch:(NSString*)text2
{
    if (text.length == 0)
        return NO;
    return [text isEqualToString:text2];
}

-(BOOL)validatePhone:(NSString*)text
{
    if (text.length < 10) {
        return NO;
    }
    
    NSString * numsOnly = [[text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    if (numsOnly.length == 11 && [numsOnly hasPrefix:@"1"])
        return YES;
    else if (numsOnly.length == 10 && ![numsOnly hasPrefix:@"1"])
        return YES;
    
    return NO;
}

-(NSString*)trimSpaces:(NSString*)text
{
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


@end
