//
//  ChangeView.h
//  Stocks+
//
//  Created by Noah Martin on 8/22/14.
//  Copyright (c) 2014 Noah Martin. All rights reserved.
//

@import UIKit;

@protocol ChangeViewDelegate <NSObject>

-(void)clicked:(UIView*)view;

@end

@interface ChangeView : UIView

@property id<ChangeViewDelegate> delegate;

-(void)setChange:(BOOL)positive;

@end
