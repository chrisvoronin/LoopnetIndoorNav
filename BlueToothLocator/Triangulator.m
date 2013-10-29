//
//  Triangulator.m
//  BlueToothLocator
//
//  Created by Chris Voronin on 10/16/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import "Triangulator.h"

@implementation Triangulator

#define rad2deg(a) (a * 57.295779513082);
#define deg2rad(a) (a * 0.017453292519);

+(CGPoint)fromTopTriangleWithLeft:(float)left right:(float)right between:(float)between rightStart:(CGPoint)rightStart
{
    float cos = (pow(right, 2) + pow(between, 2) - pow(left, 2)) / (2 * right * between);
    float angle = rad2deg(acos(cos));
    angle += 90;
    
    return [self calcEndPoint:rightStart len:right angle:angle];
}

+(CGPoint)fromLeftTriangleWithTop:(float)top bottom:(float)bottom between:(float)between topStart:(CGPoint)topStart
{
    
    float cos = (pow(between, 2) + pow(top, 2) - pow(bottom, 2)) / (2 * top * between);
    float angle = rad2deg(acos(cos));
    //angle = 90 - angle;
    
    return [self calcEndPoint:topStart len:top angle:angle];
}

+(CGPoint)fromRightTriangleWithTop:(float)top bottom:(float)bottom between:(float)between topStart:(CGPoint)topStart
{
    float cos = (pow(between, 2) + pow(top, 2) - pow(bottom, 2)) / (2 * top * between);
    float angle = rad2deg(acos(cos));
    angle += 90;
    
    return [self calcEndPoint:topStart len:top angle:angle];
}

+(CGPoint)fromBottomTriangleWithLeft:(float)left right:(float)right between:(float)between rightStart:(CGPoint)rightStart
{
    float cos = (pow(right, 2) + pow(between, 2) - pow(left, 2)) / (2 * right * between);
    float angle = rad2deg(acos(cos));
    angle += 180;
    
    return [self calcEndPoint:rightStart len:right angle:angle];
}

+(CGPoint)calcEndPoint:(CGPoint)ptStart len:(float)len angle:(float)angle
{
    float radAngle = deg2rad(angle);
    CGPoint pt;
    pt.x = ptStart.x + len * cos(radAngle);
    pt.y = ptStart.y + len * sin(radAngle);
    return pt;
}

@end
