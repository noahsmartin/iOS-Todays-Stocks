//
//  StockCell.m
//  Today's Stocks
//
//  Created by Noah Martin on 9/21/14.
//
//

#import "NewsArticle.h"
#import "StockCell.h"

@interface StockCell() <GraphViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *changeText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphHorizontalSpace;
@property id<ChangeViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *maxText;
@property (weak, nonatomic) IBOutlet UILabel *minText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *newsWidth;
@property (weak, nonatomic) IBOutlet UIView *newsContainer;
@property (weak, nonatomic) IBOutlet UIButton *newsFirstButton;
@property (weak, nonatomic) IBOutlet UIButton *newsSecondButton;
@property (weak, nonatomic) IBOutlet UIButton *newsThirdButton;
@property (weak, nonatomic) IBOutlet UIButton *newsFourthButton;
@property BOOL addedLines;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerWidth;

@end

@implementation StockCell

-(void)setViewNeedsDisplay {
    [self.graphView setNeedsDisplay];
    [self setText];
    double change = [self.graphData.change doubleValue];
    [self.changeTextBackground setChange:change >= 0];
    self.totalText.text = [NSString stringWithFormat:@"%.2f", self.graphData.realTimePrice];
    double max = [self.graphData getMaxValue];
    double min = [self.graphData getMinValue];
    NSString* format = ((int) max - min) == 0 ? @"%.1f" : @"%.0f";
    self.maxText.text = [NSString stringWithFormat:format, max];
    self.minText.text = [NSString stringWithFormat:format, min];
    [self.changeText setNeedsDisplay];
    [self.changeTextBackground setNeedsDisplay];
    if(!self.addedLines) {
        self.addedLines = YES;
    }
    if(self.graphData.articles.count) {
        [self.newsFirstButton setTitle:[self.graphData.articles.firstObject description] forState:UIControlStateNormal];
        
        if(self.graphData.articles.count > 1)  {
            [self.newsSecondButton setTitle:[[self.graphData
                                              .articles objectAtIndex:1] description] forState:UIControlStateNormal];
        }
        if(self.graphData.articles.count > 2) {
            [self.newsThirdButton setTitle:[[self.graphData
                                              .articles objectAtIndex:2] description] forState:UIControlStateNormal];
        }
        if(self.graphData.articles.count > 3) {
            [self.newsFourthButton setTitle:[[self.graphData.articles objectAtIndex:3] description] forState:UIControlStateNormal];
        }
    }
    [self.graphView setDelegate:self];
    [self.changeTextBackground setDelegate:self.delegate];
    [self setNeedsDisplay];
}

-(void)setText {
    NSString* text;
    if(self.percent) {
        double change = self.graphData.changepercent;
        text = [NSString stringWithFormat:@"%.2f%@", [self positiveValue:change], @"%"];
    } else {
        double change = [self.graphData.change doubleValue];
        text = [NSString stringWithFormat:@"%.2f", [self positiveValue:change]];
    }
    self.changeText.text = text;
}

-(void)hideNews {
    if(self.graphHorizontalSpace.constant ==0) {
        [self.newsContainer setHidden:YES];
    }
}

-(double)positiveValue:(double)value {
    if(value < 0)
        return -1 * value;
    return value;
}

-(void)setData:(StockGraph*)graphData {
    self.newsFirstButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.newsSecondButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.newsThirdButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.newsFourthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.graphView.data = graphData;
    self.graphData = graphData;
    self.symbolName.text = ((StockGraph*) self.graphData).symbol;
    double change = [((StockGraph*) self.graphData).change doubleValue];
    self.totalText.text = [NSString stringWithFormat:@"%.2f", ((StockGraph*) self.graphData).realTimePrice];
    [self setText];
    [self.changeTextBackground setChange:change >= 0];
    [self setViewNeedsDisplay];
}

-(void)setChangeDelegate:(id<ChangeViewDelegate>)delegate {
    self.delegate = delegate;
    [self.changeTextBackground setDelegate:delegate];
}

-(void)graphClicked:(UIView*)view {
    float current = self.graphHorizontalSpace.constant;
    if(current == 0) {
        if(self.graphData.articles.count) {
            self.containerWidth.constant = view.frame.size.width*(3.0/4);
            self.graphHorizontalSpace.constant = view.frame.size.width*(3.0/4);
            [view setNeedsUpdateConstraints];
            [UIView animateWithDuration:0.25f animations:^{
                [view layoutIfNeeded];
            }];
            [UIView transitionWithView:self.newsContainer
                              duration:0.4
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:NULL
                            completion:NULL];
            
            self.newsContainer.hidden = NO;
        }
    } else {
        self.graphHorizontalSpace.constant = 0;
        [view setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:0.25f animations:^{
            [view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [view setNeedsDisplay];
        }];
        [UIView transitionWithView:self.newsContainer
                          duration:0.4
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:NULL
                        completion:NULL];
        
        self.newsContainer.hidden = YES;
    }
}

-(IBAction)firstNewsClicked:(id)sender {
    NewsArticle* article = self.graphData.articles.firstObject;
    [self.newsDelegate openArticle:article];
}

-(IBAction)secondNewsClicked:(id)sender {
    NewsArticle* article = [self.graphData.articles objectAtIndex:1];
    [self.newsDelegate openArticle:article];
}

-(IBAction)thirdNewsClicked:(id)sender {
    NewsArticle* article = [self.graphData.articles objectAtIndex:2];
    [self.newsDelegate openArticle:article];
}

-(IBAction)fourthNewsClicked:(id)sender {
    NewsArticle* article = [self.graphData.articles objectAtIndex:3];
    [self.newsDelegate openArticle:article];
}

@end
