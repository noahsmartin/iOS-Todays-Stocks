//
//  StockCell.h
//  Today's Stocks
//
//  Created by Noah Martin on 9/21/14.
//
//

#import "GraphView.h"
#import "ChangeView.h"
#import <Foundation/Foundation.h>
#import "NewsArticle.h"
@import UIKit;

@protocol NewsDelegate<NSObject>

-(void)openArticle:(NewsArticle*)article;

@end

@interface StockCell : UITableViewCell
@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *symbolName;
@property (weak, nonatomic) IBOutlet UILabel *totalText;
@property (weak, nonatomic) IBOutlet ChangeView *changeTextBackground;

@property BOOL percent;
@property BOOL showColor;

@property StockGraph* graphData;

@property id<NewsDelegate> newsDelegate;

-(void)setData:(StockGraph*)graphView;

-(void)setText;

-(void)hideNews;

-(void)setChangeDelegate:(id<ChangeViewDelegate>)delegate;

@end
