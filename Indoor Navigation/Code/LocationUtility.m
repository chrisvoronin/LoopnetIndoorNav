//
//  LocationUtility.m
//  BlueToothLocator
//
//  Created by Chris Voronin on 11/6/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "LocationUtility.h"
#import "ActiveBeacon.h"
#import "BeaconPair.h"

@implementation LocationUtility

-(id)initWithMaxWidth:(float)max andMeterInPixels:(float)mip andDelegate:(id<LocationUtilityProtocol>)del
{
    self = [super init];
    if (self)
    {
        meterInPixels = mip;
        maxWidth = max;
        self.delegate = del;
        
        priorRect = CGRectZero;
        
        beaconCoordinates = [NSMutableDictionary dictionary];
        ptTopLeft = CGPointMake(447, 143);
        ptBottomRight = CGPointMake(644, 261);
    }
    return self;
}

-(CGRect)getRectFromActiveBeacons:(NSArray*)beacons
{
    CGRect currRect = [self makeBeaconSquareFromBeacons:beacons];
    return currRect;
    
    
    float dist = [self distanceBetweenRectCenters:currRect rect2:priorRect];
    
    //NSLog(@"Distance Rects = %f", dist);
    
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

-(CGRect)getRectFromActiveBeaconsDoubledUp:(NSArray*)beacons
{
    CGRect currRect = [self makeBeaconSquareFromBeacons2:beacons];
    return currRect;
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
    // for each beacon draw circle of how far it can go.
    // find min/max x/y of each circle
    // find overlaps
    // draw overlaps
    CGRect rectArray[30];
    int rectCount = (int)beacons.count;
    
    foundCloseOne = false;
    
    for (int i = 0; i < rectCount; i++)
    {
        ActiveBeacon * b = beacons[i];
        
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
    if (beacons.count > 0)
    {
        intersec = rectArray[0];
        if (CGRectIntersectsRect(intersec, priorRect))
        {
            intersec = CGRectIntersection(intersec, priorRect);
        }
    }
    
    if (rectCount > 1 && !foundCloseOne)
    {
        if (CGRectIntersectsRect(rectArray[0], rectArray[1]))
        {
            intersec = CGRectIntersection(rectArray[0], rectArray[1]);
        }
        else
        {
            // this is new for adding between distance.
            CGPoint center1 = CGPointMake(rectArray[0].origin.x + rectArray[0].size.width, rectArray[0].origin.y + rectArray[0].size.height);
            CGPoint center2 = CGPointMake(rectArray[1].origin.x + rectArray[1].size.width, rectArray[1].origin.y + rectArray[1].size.height);

            CGPoint midPoint = CGPointMake((center1.x + center2.x)/2, (center1.y + center2.y)/2);
            int width = meterInPixels * 5.0;
            intersec = CGRectMake(midPoint.x - width/2, midPoint.y - width/2, width, width);
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
    
    //intersec.size.width = maxWidth;
    //intersec.size.height = maxWidth;
    
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
    
    priorRect = intersec;
    
    return intersec;
}

-(CGRect)makeBeaconSquareFromBeacons2:(NSArray*)beacons
{
    NSMutableArray * shortList = [NSMutableArray array];
    
    // filter far beacons
    for (ActiveBeacon * b in beacons)
    {
        if (b.distance <= 6.5)
        {
            [shortList addObject:b];
        }
    }
    
    // for each beacon draw circle of how far it can go.
    // find min/max x/y of each circle
    // find overlaps
    // draw overlaps
    int rectCount = (int)shortList.count;
    
    foundCloseOne = false;
    
    // place beacons into pairs
    
    BeaconPair * beaconPairs[4];
    beaconPairs[0] = [[BeaconPair alloc] init];
    beaconPairs[1] = [[BeaconPair alloc] init];
    beaconPairs[2] = [[BeaconPair alloc] init];
    beaconPairs[3] = [[BeaconPair alloc] init];
    
    for (int i = 0; i < rectCount; i++)
    {
        ActiveBeacon * b = shortList[i];
        
        if (b.beaconID == 1 || b.beaconID == 2)
        {
            if (b.beaconID == 2)
                beaconPairs[0].beacon2 = b;
            else
                beaconPairs[0].beacon1 = b;
            beaconPairs[0].count ++;
        }
        else if (b.beaconID == 3 || b.beaconID == 4)
        {
            if (b.beaconID == 5)
                beaconPairs[1].beacon2 = b;
            else
                beaconPairs[1].beacon1 = b;
            beaconPairs[1].count ++;
        }
        else if (b.beaconID == 5 || b.beaconID == 6)
        {
            if (b.beaconID == 6)
                beaconPairs[2].beacon2 = b;
            else
                beaconPairs[2].beacon1 = b;
            beaconPairs[2].count ++;
        }
        else
        {
            if (b.beaconID == 8)
                beaconPairs[3].beacon2 = b;
            else
                beaconPairs[3].beacon1 = b;
            beaconPairs[3].count ++;
        }
    }
    
    NSMutableArray * array = [[NSMutableArray alloc]init];
    for (int i = 0; i < 4; i++)
    {
        if (beaconPairs[i].count > 0)
            [array addObject:beaconPairs[i]];
    }
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        BeaconPair * first = obj1;
        BeaconPair * second = obj2;
        if (first.confidenceValue > second.confidenceValue)
            return NSOrderedAscending;
        else if (first.confidenceValue < second.confidenceValue)
            return NSOrderedDescending;
        return NSOrderedSame;
    }];

    
    //order by highest confidence.
    // map out from there.
    CGRect intersec;
    
    for (int i = 0; i < array.count; i++)
    {
        BeaconPair * bp = array[i];
        CGPoint pt1 = bp.beacon1 ? [self getBeaconXYCoords:bp.beacon1] : CGPointZero;
        CGPoint pt2 = bp.beacon2 ? [self getBeaconXYCoords:bp.beacon2] : CGPointZero;
        CGRect rect = [bp getRectFromBeaconPoints:pt1 and2:pt2 meterInPoints:meterInPixels];
        //NSLog(@"%f, %f, %f, %f, %i", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, i);
        if (i == 0)
            intersec = rect;
        else
        {
            if (CGRectIntersectsRect(rect, intersec))
            {
                intersec = CGRectIntersection(rect, intersec);
            }
        }
    }
    
    
    if (intersec.size.width == 0.0 || intersec.size.height == 0.0 || intersec.origin.x == 0.0 || intersec.origin.y == 0.0)
    {
        NSLog(@"ZERO");
    }
    return intersec;

    //intersec.size.width = maxWidth;
    //intersec.size.height = maxWidth;
    
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
