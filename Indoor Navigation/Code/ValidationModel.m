//
//  ValidationModel.m
//  SmartSwipe
//
//  Created by Chris Voronin on 10/28/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "ValidationModel.h"

@implementation ValidationModel

-(id)initWithField:(id<UITextInput>)f andValidationType:(ValidationType)valType andLength:(int)length
{
    self = [super init];
    if (self)
    {
        self.field = f;
        self.validationType = valType;
        self.length = length;
    }
    return self;
}

-(id)initWithField:(id<UITextInput>)f andValidationType:(ValidationType)valType
{
    self = [super init];
    if (self)
    {
        self.field = f;
        self.validationType = valType;
        self.length = 0;
    }
    return self;
}

-(id)initWithField:(id<UITextInput>)f mustMatch:(id<UITextInput>)fmatch
{
    self = [super init];
    if (self)
    {
        self.field = f;
        self.fieldMatch = fmatch;
        self.validationType = ValidationMustMatch;
        self.length = 0;
    }
    return self;
}


@end
