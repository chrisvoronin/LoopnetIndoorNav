//
//  GridViewSimple.m
//  BlueToothLocator
//
//  Created by Chris Voronin on 11/7/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "GridViewSimple.h"
#import "BeaconCoordinates.h"

@implementation GridViewSimple

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        beaconCoordinates = [NSMutableArray array];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setBeacons:(NSArray*)beaconCoordinatesArray
{
    beaconCoordinates = [NSMutableArray arrayWithArray:beaconCoordinatesArray];
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    UIColor * inactive = [UIColor blueColor];
    //UIColor * active = [UIColor redColor];
    
    for (BeaconCoordinates* b in beaconCoordinates)
    {
        CGPoint pt = b.coordinate;
        if (CGRectContainsPoint(rect, pt))
        {
            CGRect rect = CGRectMake(pt.x - 2, pt.y - 2 , 4, 4);
        
            CGContextAddEllipseInRect(context, rect);
            
            CGContextSetFillColor(context, CGColorGetComponents([inactive CGColor]));
            CGContextFillPath(context);
        }
    }
}


@end
