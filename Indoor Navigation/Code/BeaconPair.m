//
//  BeaconPair.m
//  Indoor Navigation
//
//  Created by Chris Voronin on 11/12/13.
//  Copyright (c) 2013 Better Web Now. All rights reserved.
//

#import "BeaconPair.h"

@implementation BeaconPair

-(float)getMinDistance
{
    if (self.count == 2)
        return MIN(self.beacon1.distance, self.beacon2.distance);
    
    if (self.beacon1)
        return self.beacon1.distance;
    if (self.beacon2)
        return self.beacon2.distance;
    
    return -1;
}
-(float)getAverageDistance
{
    if (self.count == 2)
        return (self.beacon1.distance + self.beacon2.distance) / 2.0;
    
    if (self.beacon1)
        return self.beacon1.distance;
    
    if (self.beacon2)
        return self.beacon2.distance;
    
    return -1;
}

-(int)confidenceValue
{
    if (self.count == 0)
        return 0;
    
    int confidence = 0;
    confidence += self.count;
    
    if (self.count == 2)
    {
        if ( abs(self.beacon1.distance - self.beacon2.distance) < 1)
        {
            if (self.beacon1 && self.beacon1.distance < 1)
                confidence += 10;
            else if (self.beacon1 && self.beacon1.distance < 2)
                confidence += 6;
            
            if (self.beacon2 && self.beacon2.distance < 1)
                confidence += 10;
            else if (self.beacon2 && self.beacon2.distance < 2)
                confidence += 6;
        }
    }
    
    if (self.beacon1 && self.beacon1.distance < 1)
        confidence += 6;
    else if (self.beacon1 && self.beacon1.distance < 2)
        confidence += 3;
    
    if (self.beacon2 && self.beacon2.distance < 1)
        confidence += 6;
    else if (self.beacon2 && self.beacon2.distance < 2)
        confidence += 3;
    
    return confidence;
}

-(CGRect)getRectFromBeaconPoints:(CGPoint)p1 and2:(CGPoint)p2 meterInPoints:(float)mip
{
    CGRect rect;
    CGRect rect1, rect2;
    rect1 = CGRectZero;
    rect2 = CGRectZero;
    
    if (self.beacon1)
    {
        
        float b1dist = (MAX(self.beacon1.distance, 1) * mip);
        rect1 = CGRectMake(p1.x - b1dist, p1.y - b1dist, b1dist * 2, b1dist * 2);
    }
    if (self.beacon2)
    {
        float b2dist = (MAX(self.beacon2.distance, 1) * mip);
        rect2 = CGRectMake(p2.x - b2dist, p2.y - b2dist, b2dist * 2, b2dist * 2);
    }
    // we have 2
    if (self.count == 2)
    {
        // start with smallest one.
        rect = rect1.size.width < rect2.size.width ? rect1 : rect2;
    }
    else
    {
        rect = rect1.size.width > 0 ? rect1 : rect2;
    }
    return rect;
}

@end
