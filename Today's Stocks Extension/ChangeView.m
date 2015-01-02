//
//  ChangeView.m
//  Stocks+
//
//  Created by Noah Martin on 8/22/14.
//  Copyright (c) 2014 Noah Martin. All rights reserved.
//

#import "ChangeView.h"

@implementation ChangeView

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
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
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDown:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGesture];
        return self;
    }
    return nil;
}

-(void)setChange:(BOOL)positive {
    UIColor* color = positive ? [UIColor colorWithRed:0.13 green:0.8 blue:0.13 alpha:1] : [UIColor redColor];
    self.layer.backgroundColor = [color CGColor];
    self.layer.cornerRadius = 3;
}

-(void)tapDown:(UITapGestureRecognizer*)gestureRecognizer {
    [self.delegate clicked:self];
}

@end
