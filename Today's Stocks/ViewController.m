//
//  ViewController.m
//  Today's Stocks
//
//  Created by Noah Martin on 9/13/14.
//
//

#import "StockGraph.h"
#import "StockRequest.h"
#import "ViewController.h"

@interface ViewController ()
@property NSMutableArray* graphs;
@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.noahstocks.TodayExtensionSharingDefaults"];
    NSData* data = [sharedDefaults dataForKey:@"graphs"];
    if(data) {
        self.graphs = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    } else {
        self.graphs = [[NSMutableArray alloc] init];
    }
    if(!self.graphs.count) {
        StockRequest* request = [[StockRequest alloc] init];
        [request startRequestWithSymbol:@"AAPL" duration:DAY withBlock:^(StockGraph *graph) {
            graph.name = @"Apple Inc.";
            if([self.graphs containsObject:graph]) {
                [(StockGraph*) [self.graphs objectAtIndex:[self.graphs indexOfObject:graph]] updateWithData:graph];
            } else {
                [self.graphs addObject:graph];
                [self.tableView reloadData];
            }
            [self saveUserDefaults];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.noahstocks.TodayExtensionSharingDefaults"];
    NSData* data = [sharedDefaults dataForKey:@"graphs"];
    if(data) {
        self.graphs = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    } else {
        self.graphs = [[NSMutableArray alloc] init];
    }
    [self.tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.graphs.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = [(StockGraph*) [self.graphs objectAtIndex:indexPath.row] symbol];
    cell.detailTextLabel.text = [(StockGraph*) [self.graphs objectAtIndex:indexPath.row] name];
    return cell;
}

-(void)saveUserDefaults {
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.graphs];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.noahstocks.TodayExtensionSharingDefaults"];
    [sharedDefaults setObject:data forKey:@"graphs"];
    [sharedDefaults synchronize];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.graphs removeObjectAtIndex:indexPath.row];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        [self saveUserDefaults];
    }
}

@end
