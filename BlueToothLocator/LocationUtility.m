//
//  LocationUtility.m
//  BlueToothLocator
//
//  Created by Chris Voronin on 11/6/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "LocationUtility.h"
#import "ActiveBeacon.h"

@implementation LocationUtility

-(id)initWithMaxWidth:(float)max andMeterInPixels:(float)mip
{
    self = [super init];
    if (self)
    {
        meterInPixels = mip;
        maxWidth = max;
        beaconCoordinates = [NSMutableDictionary dictionary];
        ptTopLeft = CGPointMake(467, 143);
        ptBottomRight = CGPointMake(644, 261);
    }
    return self;
}

-(CGRect)getRectFromActiveBeacons:(NSArray*)beacons
{
    CGRect currRect = [self makeBeaconSquareFromBeacons:beacons];
    float dist = [self distanceBetweenRectCenters:currRect rect2:priorRect];
    
    NSLog(@"Distance Rects = %f", dist);
    
    if (dist <= 55 || foundCloseOne)
    {
        priorRect = currRect;
        return currRect;
    }
    else
    {
        return priorRect;
    }
}

-(void)setBeacons:(NSArray*)beaconCoordinatesArray
{
    for(BeaconCoordinates * b in beaconCoordinatesArray)
    {
        [beaconCoordinates setObject:b forKey:[NSNumber numberWithInt:b.beaconID]];
    }
}


#pragma mark - Private Methods

-(CGRect)makeBeaconSquareFromBeacons:(NSArray*)beacons
{
    NSMutableArray * shortList = [NSMutableArray array];
    
    // filter far beacons
    for (ActiveBeacon * b in beacons)
    {
        if (b.distance <= 5.5)
        {
            [shortList addObject:b];
        }
    }
    
    // for each beacon draw circle of how far it can go.
    // find min/max x/y of each circle
    // find overlaps
    // draw overlaps
    CGRect rectArray[30];
    int rectCount = shortList.count;
    
    foundCloseOne = false;
    
    for (int i = 0; i < rectCount; i++)
    {
        ActiveBeacon * b = shortList[i];
        
        CGPoint pt = [self getBeaconXYCoords:b];
        float xyDist = b.distance * meterInPixels;
        int minX = pt.x - xyDist;
        int minY = pt.y - xyDist;
        rectArray[i] = CGRectMake(minX, minY, xyDist * 2, xyDist * 2);
        
        if (b.distance <= 1.7)
        {
            foundCloseOne = true;
            
            [self.delegate cameNearBeaconID:b.beaconID];
            break;
        }
    }
    
    CGRect intersec;
    if (shortList.count > 0)
    {
        intersec = rectArray[0];
        if (priorRect.size.width == 0)
            priorRect = intersec;
    }
    
    if (rectCount > 1 && !foundCloseOne)
    {
        if (CGRectIntersectsRect(rectArray[0], rectArray[1]))
        {
            intersec = CGRectIntersection(rectArray[0], rectArray[1]);
        }
        
        if (rectCount > 2)
        {
            if (CGRectIntersectsRect(rectArray[1], rectArray[2]))
            {
                CGRect intersec2 = CGRectIntersection(rectArray[1], rectArray[2]);
                if (CGRectIntersectsRect(intersec, intersec2))
                    intersec = CGRectIntersection(intersec, intersec2);
            }
            if (CGRectIntersectsRect(rectArray[0], rectArray[2]))
            {
                CGRect intersec3 = CGRectIntersection(rectArray[0], rectArray[2]);
                if (CGRectIntersectsRect(intersec, intersec3))
                    intersec = CGRectIntersection(intersec, intersec3);
            }
        }
    }
    
    intersec.size.width = maxWidth;
    intersec.size.height = maxWidth;
    
    // constrain bounds by adjustment.
    // y pos
    if (intersec.origin.y + intersec.size.height > ptBottomRight.y)
    {
        int len = (intersec.origin.y + intersec.size.height) - ptBottomRight.y;
        intersec.origin.y -= len;
    }
    else if (intersec.origin.y < ptTopLeft.y)
    {
        intersec.origin.y = ptTopLeft.y;
    }
    
    // x pos
    if (intersec.origin.x < ptTopLeft.x)
    {
        intersec.origin.x = ptTopLeft.x;
    }
    else if (intersec.origin.x + intersec.size.width > ptBottomRight.x)
    {
        int len = (intersec.origin.x + intersec.size.width) - ptBottomRight.x;
        intersec.origin.x -= len;
    }
    
    return intersec;
}

-(CGPoint)getBeaconXYCoords:(ActiveBeacon*)beacon
{
    NSNumber * bid = [NSNumber numberWithInt:beacon.beaconID];
    BeaconCoordinates * coords = [beaconCoordinates objectForKey:bid];
    CGPoint pt = coords.coordinate;
    return pt;
}


-(float)distanceBetweenRectCenters:(CGRect)rect1 rect2:(CGRect)rect2
{
    CGPoint center1;
    center1.x = rect1.origin.x + (rect1.size.width / 2);
    center1.y = rect1.origin.y + (rect1.size.height / 2);
    
    CGPoint center2;
    center2.x = rect2.origin.x + (rect2.size.width / 2);
    center2.y = rect2.origin.y + (rect2.size.height / 2);
    
    double dy = abs(center2.y - center1.y);
    double dx = abs(center2.x - center1.x);
    
    float dist = sqrt(dy * dy + dx * dx);
    
    return dist;
}


@end
