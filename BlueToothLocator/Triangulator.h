//
//  Triangulator.h
//  BlueToothLocator
//
//  Created by Chris Voronin on 10/16/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Triangulator : NSObject

+(CGPoint)fromTopTriangleWithLeft:(float)left right:(float)right between:(float)between rightStart:(CGPoint)rightStart;

+(CGPoint)fromLeftTriangleWithTop:(float)top bottom:(float)bottom between:(float)between topStart:(CGPoint)topStart;

+(CGPoint)fromRightTriangleWithTop:(float)top bottom:(float)bottom between:(float)between topStart:(CGPoint)topStart;

+(CGPoint)fromBottomTriangleWithLeft:(float)left right:(float)right between:(float)between rightStart:(CGPoint)rightStart;

@end
