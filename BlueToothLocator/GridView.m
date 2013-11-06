//
//  GridView.m
//  BlueToothLocator
//
//  Created by Chris Voronin on 9/30/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "GridView.h"
#import "ActiveBeacon.h"
#import "Triangulator.h"

#define rad2deg(a) (a * 57.295779513082);
#define deg2rad(a) (a * 0.017453292519);

@implementation GridView


@synthesize algorithm;

-(id)initWithFrame:(CGRect)frame beaconsInRow:(int)beaconsInRow numRows:(int)r;
{
    self = [super initWithFrame:frame];
    if (self) {
        beaconsInARow = beaconsInRow;
        rows = r;
        
        activeBeacons = [NSMutableArray array];
        self.opaque = NO;

        //columns
        columnWidth = self.frame.size.width / (beaconsInARow + 1);
        rowHeight = self.frame.size.height / (rows + 1);
        beaconDistance = 5.0;
        
        // first
        ActiveBeacon * ba = [[ActiveBeacon alloc] initWithBeaconID:1 distance:1];
        ptTopLeft = [self getBeaconXYCoords:ba];
        
        // last
        ba.beaconID = beaconsInARow * rows;
        ptBottomRight = [self getBeaconXYCoords:ba];
        
        maxWidth = (columnWidth / 5) * 2.5;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setDownedBeacons:(NSMutableArray*)beacons
{
    downedBeacons = beacons;
    [self setNeedsDisplay];
}

-(void)setBeaconsActive:(NSMutableArray*)beacons
{
    activeBeacons = beacons;
    [self setNeedsDisplay];
}

-(CGRect)makeBeaconSquare
{
    NSMutableArray * shortList = [NSMutableArray array];
    
    // filter far beacons
    for (ActiveBeacon * b in activeBeacons)
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
    CGRect rectArray[10];
    int rectCount = shortList.count;
    
    foundCloseOne = false;
    
    for (int i = 0; i < rectCount; i++)
    {
        ActiveBeacon * b = shortList[i];
        
        CGPoint pt = [self getBeaconXYCoords:b];
        float xyDist = b.distance * columnWidth / beaconDistance;
        int minX = pt.x - xyDist;
        int minY = pt.y - xyDist;
        rectArray[i] = CGRectMake(minX, minY, xyDist * 2, xyDist * 2);
        
        if (b.distance <= 1.5)
        {
            foundCloseOne = true;
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

- (void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor clearColor];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    CGFloat widthV = self.frame.size.width;
    CGFloat heightV = self.frame.size.height;

    
    //columns
    for(int i = 1; i <= beaconsInARow; i++)
    {
        CGPoint startPoint;
        CGPoint endPoint;
        
        startPoint.x = columnWidth * i;
        startPoint.y = 0.0f;
        
        endPoint.x = startPoint.x;
        endPoint.y = heightV;
        
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextStrokePath(context);
    }
    
    //rows
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    for(int j = 1; j <= rows; j++)
    {
        CGPoint startPoint;
        CGPoint endPoint;
        
        startPoint.x = 0.0f;
        startPoint.y = rowHeight * j;
        
        endPoint.x = widthV;
        endPoint.y = startPoint.y;
        
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        CGContextStrokePath(context);
    }
    
    //circles
    UIColor * clr = [UIColor blueColor];
    UIColor * clrActive = [UIColor redColor];
    //UIColor * bcnDisabled = [UIColor greenColor];
    
    int beaconID;
    for (int i = 1; i <= beaconsInARow; i++)
    {
        for (int j = 1; j <= rows; j++)
        {
            beaconID = ((j - 1) * beaconsInARow + i);
            CGRect rect = CGRectMake(columnWidth * i - 10, j * rowHeight - 10, 20, 20);
            
            CGContextAddEllipseInRect(context, rect);
            
            // in the future make these id's come from an array. (simulate 10 & 11)
            if ([self activeBeaconsHaveBeaconID:beaconID])
                CGContextSetFillColor(context, CGColorGetComponents([clrActive CGColor]));
            else
                CGContextSetFillColor(context, CGColorGetComponents([clr CGColor]));
            CGContextFillPath(context);
        }
    }
    
    CGRect beaconSquare = [self makeBeaconSquare];
    float dist = [self distanceBetweenRectCenters:beaconSquare rect2:priorRect];
    
    NSLog(@"Distance Rects = %f", dist);
    
    if (dist <= 120 || foundCloseOne)
    {
        priorRect = beaconSquare;
        CGContextSetRGBStrokeColor(context, 1.0, 0, 0, 1.0);
        CGContextStrokeRect(context, beaconSquare);
    }
    else
    {
        CGContextSetRGBStrokeColor(context, 1.0, 0, 0, 1.0);
        CGContextStrokeRect(context, priorRect);
    }
    
    
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

-(bool)activeBeaconsHaveBeaconID:(int)beaconID
{
    for (ActiveBeacon * b in activeBeacons)
    {
        if (b.beaconID == beaconID)
            return true;
    }
    return false;
}

-(CGPoint)getBeaconColRow:(ActiveBeacon*)beacon
{
    int row = 3;
    int column = 1;
    int bid = beacon.beaconID;
    
    if (bid <= 4)
        row = 1;
    else if (bid <= 8)
        row = 2;
    
    if (bid == 2 || bid == 6 || bid == 10)
        column = 2;
    else if (bid == 3 || bid == 7 || bid == 11)
        column = 3;
    else if (bid == 4 || bid == 8 || bid == 12)
        column = 4;

    return CGPointMake(column, row);
}

-(CGPoint)getBeaconXYCoords:(ActiveBeacon*)beacon
{
    CGPoint pt = [self getBeaconColRow:beacon];
    
    CGPoint ptCoords;
    ptCoords.x = pt.x * columnWidth;
    ptCoords.y = (pt.y) * rowHeight;
    
    return ptCoords;
}

#pragma mark - Old Code.

/**
 * Calculates end point
 @author Chris V
 @param ptStart starting Point
 @param len Length between start and end
 @param angle Angle in degrees (NOT RADIANS) between the two
 @return resulting end point coordinates.
 */
-(CGPoint)calcEdnPoint:(CGPoint)ptStart len:(float)len angle:(float)angle
{
    float radAngle = deg2rad(angle);
    CGPoint pt;
    pt.x = ptStart.x + len * cos(radAngle);
    pt.y = ptStart.y + len * sin(radAngle);
    return pt;
}

-(CGPoint)convertPointToCoordinates:(CGPoint)point
{
    CGPoint result;
    
    result.x = columnWidth * point.x / 5;
    result.y = rowHeight * point.y / 5;
    return result;
}

-(CGPoint)getBeaconPointInMeters:(ActiveBeacon*)beacon
{
    CGPoint pt = [self getBeaconColRow:beacon];
    pt.x *= beaconDistance;
    pt.y *= beaconDistance;
    return pt;
}

-(CGRect)determineQuadrantXY:(NSArray*)beacons
{
    int minX, maxX, minY, maxY;
    
    for (ActiveBeacon * b in beacons)
    {
        CGPoint pt = [self getBeaconXYCoords:b];
        if (pt.x < minX)
            minX = pt.x;
        if (pt.x > maxX)
            maxX = pt.x;
        if (pt.y < minY)
            minY = pt.y;
        if (pt.y > maxY)
            maxY = pt.y;
    }
    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

-(void)drawBeaconsZZ:(CGContextRef)context
{
    [activeBeacons sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (obj2 == [NSNull null])
            return YES;
        NSNumber * beaconID1 = [NSNumber numberWithInt: ((ActiveBeacon*)obj1).beaconID];
        NSNumber * beaconID2 = [NSNumber numberWithInt: ((ActiveBeacon*)obj2).beaconID];
        return  [beaconID1 compare:beaconID2] == NSOrderedDescending;
    }];
    
    // determine quadrant.
    CGRect quadrant = [self determineQuadrantXY:activeBeacons];
    
    // triangulate from 3 beacons.
    
    if (quadrant.size.width > 0 && quadrant.size.height > 0  && activeBeacons.count >= 3)
    {
        ActiveBeacon * beacon1 = [activeBeacons objectAtIndex:0];
        ActiveBeacon * beacon2 = [activeBeacons objectAtIndex:1];
        ActiveBeacon * beacon3 = [activeBeacons objectAtIndex:2];
        
        CGPoint bp1 =[self getBeaconXYCoords:beacon1];
        CGPoint bp2 =[self getBeaconXYCoords:beacon2];
        CGPoint bp3 =[self getBeaconXYCoords:beacon3];
        
        CGPoint drawPt1, drawPt2;
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, bp1.x, bp1.y);
        CGContextAddLineToPoint(context, bp2.x, bp2.y);
        CGContextAddLineToPoint(context, bp3.x, bp3.y);
        CGContextClosePath(context);
        CGContextSetRGBFillColor(context, 1, 1, 0, 1);
        CGContextFillPath(context);
        
        if (true)
        {
            // get triangles
            if (bp1.y == bp2.y)
            {
                //top triangle found
                drawPt1 = [Triangulator fromTopTriangleWithLeft:beacon1.distance right:beacon2.distance between:beaconDistance rightStart:[self getBeaconPointInMeters:beacon2]];
                
                if (bp3.x == bp1.x)
                {
                    //left triangle
                    drawPt2 = [Triangulator fromLeftTriangleWithTop:beacon1.distance bottom:beacon3.distance between:beaconDistance topStart:[self getBeaconPointInMeters:beacon1]];
                    
                }
                else
                {
                    // right
                    drawPt2 = [Triangulator fromRightTriangleWithTop:beacon2.distance bottom:beacon3.distance between:beaconDistance topStart:[self getBeaconPointInMeters:beacon2]];
                }
            }
            else
            {
                //bottom
                drawPt1 = [Triangulator fromBottomTriangleWithLeft:beacon2.distance right:beacon3.distance between:beaconDistance rightStart:[self getBeaconPointInMeters:beacon3]];
                
                if (bp1.x == bp2.x)
                {
                    // left
                    drawPt2 = [Triangulator fromLeftTriangleWithTop:beacon1.distance bottom:beacon2.distance between:beaconDistance topStart:[self getBeaconPointInMeters:beacon1]];
                }
                else
                {
                    //right
                    drawPt2 = [Triangulator fromRightTriangleWithTop:beacon1.distance bottom:beacon3.distance between:beaconDistance topStart:[self getBeaconPointInMeters:beacon1]];
                }
            }
            
            drawPt1 = [self convertPointToCoordinates:drawPt1];
            drawPt2 = [self convertPointToCoordinates:drawPt2];
            
            
            
            CGFloat w = 10, h = 10;
            CGRect rect = CGRectMake(drawPt1.x, drawPt1.y, w, h);
            CGContextAddEllipseInRect(context, rect);
            CGContextSetFillColor(context, CGColorGetComponents([[UIColor greenColor] CGColor]));
            CGContextFillPath(context);
            
            rect = CGRectMake(drawPt2.x, drawPt2.y, w, h);
            CGContextAddEllipseInRect(context, rect);
            CGContextSetFillColor(context, CGColorGetComponents([[UIColor purpleColor] CGColor]));
            CGContextFillPath(context);
            
            CGFloat ptMinX = MIN(drawPt1.x, drawPt2.x);
            CGFloat ptMaxX = MAX(drawPt1.x, drawPt2.x);
            CGFloat ptMinY = MIN(drawPt1.y, drawPt2.y);
            CGFloat ptMaxY = MAX(drawPt1.y, drawPt2.y);
            CGFloat rectWidth = ptMaxX - ptMinX;
            if (rectWidth < 10)
                rectWidth = 10;
            CGFloat rectHeight = ptMaxY - ptMinY;
            if (rectHeight < 10)
                rectHeight = 10;
            CGRect rectLocation = CGRectMake(ptMinX, ptMinY, rectWidth, rectHeight);
            CGContextSetRGBStrokeColor(context, 1.0, 0, 0, 1.0);
            CGContextStrokeRect(context, rectLocation);
            
            /*
             
             // law of cosines = c^2 = a^2 + b^2 - 2ab * cos(C);
             float cosA = (pow(b, 2) + pow(c, 2) - pow(a, 2)) / (2 * b * c);
             float angleA = acos(cosA);
             
             float cosB = (pow(c, 2) + pow(a, 2) - pow(b, 2)) / (2 * a * c);
             float angleB = acos(cosB);
             
             float cosC = (pow(a, 2) + pow(b, 2) - pow(c, 2)) / (2* a *b);
             float angleC = acos(cosC);
             [self calcEdnPoint:0 y:0 len:0 angle:0];
             // find ref angle.  = 90 - angle.
             [self calcEdnPoint:0 y:0 len:0 angle:0];
             CGPoint pt = [self calcEdnPoint:0 y:0 len:0 angle:0];
             // calculate end point.
             */
        }
        
    }
    // build triangles.
    // determine location.
    // draw square around all possible locations.
}


@end
