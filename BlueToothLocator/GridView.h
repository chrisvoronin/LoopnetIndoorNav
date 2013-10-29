//
//  GridView.h
//  BlueToothLocator
//
//  Created by Chris Voronin on 9/30/13.
//  Copyright (c) 2013 Chris Voronin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum LocationAlgorithm : NSUInteger
{
    LocationAlgorithmTriangles,
    LocationAlgorithmCircles
} LocationAlgorithm;

@interface GridView : UIView
{
    NSMutableArray * activeBeacons;
    NSMutableArray * downedBeacons;
    CGFloat columnWidth;
    CGFloat rowHeight;
    float beaconDistance, maxWidth;
    int beaconsInARow;
    int rows;
    CGPoint ptTopLeft, ptBottomRight;
    CGRect priorRect;
}

-(id)initWithFrame:(CGRect)frame beaconsInRow:(int)beaconsInRow numRows:(int)r;

@property (nonatomic, assign) LocationAlgorithm algorithm;

-(void)setBeaconsActive:(NSMutableArray*)beacons;
-(void)setDownedBeacons:(NSMutableArray*)beacons;

@end
