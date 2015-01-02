//
//  GraphView.m
//  Stocks+
//
//  Created by Noah Martin on 8/18/14.
//  Copyright (c) 2014 Noah Martin. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        _colorCoded = YES;
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDown:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGesture];
        return self;
    }
    return nil;
}

-(instancetype)initWithFrame:(CGRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _colorCoded = YES;
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDown:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGesture];
        return self;
    }
    return nil;
}

- (void)drawRect:(CGRect)dirtyRect {
    [super drawRect:dirtyRect];
    CGRect bounds = self.bounds;
    int width = bounds.size.width;
    int height = bounds.size.height;
    long count = [self.data numberOfPoints];
    double lineSpacing = ((double) width) / 10;
    UIBezierPath* path = [[UIBezierPath alloc] init];
    [path setLineWidth:0.5];
    [[UIColor grayColor] setStroke];
    for(int i = 0; i < 10; i++) {
        [path moveToPoint:CGPointMake(i*lineSpacing, 0)];
        [path addLineToPoint:CGPointMake(i*lineSpacing, height)];
        [path stroke];
    }
    for(int i = 0; i < count-1; i++) {
        DataPoint* data1 = ((DataPoint*) [self.data.points objectAtIndex:i]);
        DataPoint* data2 = ((DataPoint*) [self.data.points objectAtIndex:i+1]);
        CGPoint point = [self cordsForDataPoint:data1];
        CGPoint point2 = [self cordsForDataPoint:data2];
        path = [[UIBezierPath alloc] init];
        [path moveToPoint:point];
        if(self.colorCoded) {
            if(data1.price < self.data.prevClose && data2.price < self.data.prevClose) {
                [[UIColor redColor] setStroke];
            } else if(data1.price < self.data.prevClose) {
                [[UIColor redColor] setStroke];
                CGPoint changePoint = [self cordsForDataPointPrice:self.data.prevClose];
                double slopeInverse = (point2.x - point.x) / (point2.y - point.y);
                changePoint.x = point.x + (changePoint.y - point.y) * slopeInverse;
                [path addLineToPoint:changePoint];
                [path stroke];
                path = [[UIBezierPath alloc] init];
                [path moveToPoint:changePoint];
                [[UIColor greenColor] setStroke];
            } else if(data2.price < self.data.prevClose) {
                [[UIColor greenColor] setStroke];
                CGPoint changePoint = [self cordsForDataPointPrice:self.data.prevClose];
                double slopeInverse = (point2.x - point.x) / (point2.y - point.y);
                changePoint.x = point.x + (changePoint.y - point.y) * slopeInverse;
                [path addLineToPoint:changePoint];
                [path stroke];
                path = [[UIBezierPath alloc] init];
                [path moveToPoint:changePoint];
                [[UIColor redColor] setStroke];
            }else {
                [[UIColor greenColor] setStroke];
            }
        } else {
            [[UIColor whiteColor] setStroke];
        }
        [path setLineWidth:0.5];
        [path addLineToPoint:point2];
        [path stroke];
    }
    if(count > 1) {
        CGPoint point = [self cordsForDataPoint:[self.data.points objectAtIndex:0]];
        UIBezierPath* path = [[UIBezierPath alloc] init];
        [path moveToPoint:CGPointMake(0, self.frame.size.height)];
        [path addLineToPoint:point];
        for(int i = 1; i < count; i++) {
            CGPoint point = [self cordsForDataPoint:[self.data.points objectAtIndex:i]];
            [path addLineToPoint:point];
        }
        point = [self cordsForDataPoint:[self.data.points objectAtIndex:count-1]];
        [path addLineToPoint:CGPointMake(point.x, self.frame.size.height)];
        [path closePath];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGGradientRef gradient;
        CGColorSpaceRef colorspace;
        size_t num_locations = 2;
        CGFloat locations[2] = { 0.0, 1.0 };
        CGFloat components[8] = { 0.35, 0.35, 0.35, 0.5,  // Start color
            0.15, 0.15, 0.15, 0.5 }; // End color
        
        colorspace = CGColorSpaceCreateDeviceRGB();
        gradient = CGGradientCreateWithColorComponents (colorspace, components, locations, num_locations);
        [path addClip];
        CGContextDrawLinearGradient (context, gradient, CGPointMake(0, self.frame.size.height), CGPointMake(0, 0), 0);
        CGGradientRelease(gradient);
        
       //  NSGradient* fillGradient = [[NSGradient alloc] initWithStartingColor:[UIColor colorWithCalibratedRed:0.35 green:0.35 blue:0.35 alpha:0.5] endingColor:[UIColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:0.5]];
       // [fillGradient drawInBezierPath:path angle:90];
    }
}

-(void)tapDown:(UITapGestureRecognizer*)gestureRecognizer {
    if([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        [self.delegate graphClicked:self];
    }
}

-(void)setColorCoded:(BOOL)colorCoded {
    _colorCoded = colorCoded;
    [self setNeedsDisplay];
}

-(CGPoint)cordsForDataPoint:(DataPoint*)dataPoint {
    CGPoint point = [self cordsForDataPointPrice:dataPoint.price];
    double width = self.bounds.size.width*2;
    double factor = width / (self.data.marketClose - self.data.marketOpen);
    point.x = ([dataPoint getTimestamp] - self.data.marketOpen) * factor;
    point.x = point.x / 2;
    return point;
}

-(CGPoint)cordsForDataPointPrice:(double)price {
    int height = self.bounds.size.height*2-4;  // 2 pixels padding on top and bottom
    double minPrice = [self.data getMinValue];
    double maxPrice = [self.data getMaxValue];
    double span = maxPrice - minPrice;
    double factor = height/span;
    double y = price - minPrice;
    double yPixel = height - (y * factor);
    yPixel /= 2;
    return CGPointMake(0, yPixel+2);
}

@end
