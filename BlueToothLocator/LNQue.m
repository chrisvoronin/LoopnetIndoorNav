//
//  LNQue.m
//  BlueToothLocator
//
//  Created by Chris Voronin on 9/17/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "LNQue.h"

@implementation LNQue
{
    int values[7];
    int currIndex;
    int prevVal;
}

-(void)addInt:(int)value
{
    prevVal = values[currIndex];
    
    if (prevVal != 0 && abs(prevVal - value) >= 20)
        return;
    
    currIndex++;
    if (currIndex == 7)
        currIndex = 0;
    
    values[currIndex] = value;
    
}

-(float)getAverage
{
    int sum = 0;
    int count = 0;
    int value = 0;
    for (int i = 0; i < 7; i++)
    {
        value = values[i];
        if (value != 0)
        {
            sum += value;
            count++;
        }
    }
    return sum / count;
}


@end
