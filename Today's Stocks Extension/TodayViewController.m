//
//  TodayViewController.m
//  Today's Stocks Extension
//
//  Created by Noah Martin on 9/13/14.
//
//

#import "TodayViewController.h"
#import "StockRequest.h"
#import "StockGraph.h"
#import "GraphView.h"
#import "StockCell.h"
#import "NewsRequest.h"
#import "NewsArticle.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding, ChangeViewDelegate, NewsDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray* graphs;
@property BOOL showPercent;
@property BOOL showMore;
@property BOOL showNext;
@property long offset;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showMore = false;
    [self loadPrefs];
    [self loadData:nil];
    // Do any additional setup after loading the view from its nib.
    [self resetContentSize];
}

-(void)loadData:(void (^)(NCUpdateResult result))completionHandler {
    if(completionHandler != nil) {
        completionHandler(NCUpdateResultNewData);
        completionHandler = nil;
    }
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.noahstocks.TodayExtensionSharingDefaults"];
    NSData* data = [sharedDefaults dataForKey:@"graphs"];
    if(data) {
        self.graphs = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
        [self requestNewData];
        if(completionHandler) {
            completionHandler(NCUpdateResultNewData);
        }
    } else {
        self.graphs = [[NSMutableArray alloc] init];
    }
    
    // Set up the widget list view controller.
    // The contents property should contain an object for each row in the list.
    if(!self.graphs.count) {
        StockRequest* request = [[StockRequest alloc] init];
        [request startRequestWithSymbol:@"AAPL" duration:DAY withBlock:^(StockGraph *graph) {
            graph.name = @"Apple Inc.";
            [self addGraph:graph];
            if(completionHandler) {
                completionHandler(NCUpdateResultNewData);
            }
        }];
    } else {
        if(completionHandler) {
            completionHandler(NCUpdateResultNewData);
        }
    }
}

-(void)requestNewData {
    for(StockGraph* graph in self.graphs) {
        StockRequest* request = [[StockRequest alloc] init];
        [request startRequestWithSymbol:graph.symbol duration:DAY withBlock:^(StockGraph *newGraph) {
            [[[NewsRequest alloc] init] getNewsForSymbol:newGraph.symbol withBlock:^(NSArray* result) {
                newGraph.articles = result;
                [self addGraph:newGraph];
            }];
            [self addGraph:newGraph];
        }];
    }
}

-(void)addGraph:(StockGraph*)graph {
    if([self.graphs containsObject:graph]) {
        [(StockGraph*) [self.graphs objectAtIndex:[self.graphs indexOfObject:graph]] updateWithData:graph];
    } else {
        [self.graphs addObject:graph];
    }
    [self.tableView reloadData];
    [self resetContentSize];
    [self saveUserDefaults];
}

-(void)loadPrefs {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.noahstocks.TodayExtensionSharingDefaults"];
    if(![sharedDefaults objectForKey:@"graphs"]) {
        self.showPercent = NO;
    } else {
        self.showPercent = [sharedDefaults boolForKey:@"showPercent"];
    }
}

- (void)resetContentSize {
    long height;
    if(!self.showMore) {
        height = 75*MIN(3, [self getStocksLeft]);
        if([self getStocksLeft] > 3) {
            height += 44;
        }
    } else {
        height = [self getStocksLeft]*75;
    }
    self.preferredContentSize = CGSizeMake(0, height);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if((self.showMore || indexPath.row < 3) && (!self.showNext || indexPath.row < [self rowCount]-1)) {
        return 75;
    }
    return 44;
}

-(long)getStocksLeft {
    return self.graphs.count-self.offset;
}

-(NSInteger)rowCount {
    if(self.showMore) {
        int num = MIN([self getStocksLeft], self.view.frame.size.height/75);
        if (num < [self getStocksLeft]) {
            self.showNext = YES;
            if(num*75 + 44 > self.view.frame.size.height) {
                num--;
            }
            return num+1;
        } else {
            self.showNext = NO;
        }
        return num;
    }
    return MIN([self getStocksLeft], 4);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self rowCount];
}

-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    defaultMarginInsets.bottom = 10;
    return defaultMarginInsets;
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.tableView reloadData];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.tableView reloadData];
    }];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if((self.showMore || indexPath.row < 3) && (!self.showNext || indexPath.row < [self.tableView numberOfRowsInSection:0]-1)) {
        StockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StockCell" forIndexPath:indexPath];
        cell.percent = self.showPercent;
        [cell setData:[self.graphs objectAtIndex:indexPath.row+self.offset]];
        [cell setChangeDelegate:self];
        cell.newsDelegate = self;
        [cell hideNews];
        return cell;
    } else if(self.showNext) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ShowMore" forIndexPath:indexPath];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ShowMore"];
        }
        cell.textLabel.text = @"Show Next...";
        return cell;
    }else {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ShowMore" forIndexPath:indexPath];
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ShowMore"];
            cell.textLabel.text = @"Show All...";
        }
        cell.textLabel.text = @"Show All...";
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.showMore && indexPath.row == 3) {
        self.showMore = YES;
        [self resetContentSize];
    } else if(self.showNext && indexPath.row == [self rowCount]-1) {
        self.offset += [self rowCount]-1;
        [self resetContentSize];
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    [self loadData:completionHandler];
}

-(void)saveUserDefaults {
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.graphs];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.noahstocks.TodayExtensionSharingDefaults"];
    [sharedDefaults setObject:data forKey:@"graphs"];
    [sharedDefaults synchronize];
}

-(void)savePrefs {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.noahstocks.TodayExtensionSharingDefaults"];
    [sharedDefaults setBool:self.showPercent forKey:@"showPercent"];
    [sharedDefaults synchronize];
}

-(void)clicked:(UIView*)view {
    self.showPercent = !self.showPercent;
    for(int i = 0; i < self.graphs.count; i++) {
        StockCell* rowController = (StockCell*) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        rowController.percent = self.showPercent;
        [rowController setText];
    }
    [self savePrefs];
}

-(void)openArticle:(NewsArticle*)article {
    [self.extensionContext openURL:article.url completionHandler:^(BOOL success) {}];
}

@end
