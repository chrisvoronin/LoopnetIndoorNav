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
            confidence += 5;
    }
    
    if (self.beacon1 && self.beacon1.distance < 1)
        confidence += 2;
    else if (self.beacon1 && self.beacon1.distance < 2)
        confidence += 1;
    
    if (self.beacon2 && self.beacon2.distance < 1)
        confidence += 2;
    else if (self.beacon2 && self.beacon2.distance < 2)
        confidence += 1;
    
    return confidence;
}

@end
