//
//  GraphView.h
//  Stocks+
//
//  Created by Noah Martin on 8/18/14.
//  Copyright (c) 2014 Noah Martin. All rights reserved.
//

@import UIKit;
#import "StockGraph.h"
#import "ChangeView.h"

@protocol GraphViewDelegate <NSObject>

-(void)graphClicked:(UIView*)view;

@end


@interface GraphView : UIView;

@property StockGraph* data;
@property (nonatomic) BOOL colorCoded;
@property id<GraphViewDelegate> delegate;

@end
