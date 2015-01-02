//
//  SearchViewController.m
//  Today's Stocks
//
//  Created by Noah Martin on 9/22/14.
//
//

#import "SymbolSearch.h"
#import "StockRequest.h"
#import "SearchViewController.h"

@interface SearchViewController() <UISearchBarDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSArray *searchResults; // Filtered search results
@property NSMutableArray* graphs;

@end

@implementation SearchViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    // Create a mutable array to contain products for the search results table.
    self.searchResults = [NSMutableArray array];
    
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.searchBar.showsCancelButton = YES;
    [self.searchController.searchBar setShowsCancelButton:YES animated:YES];
    self.searchController.searchBar.delegate = self;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.noahstocks.TodayExtensionSharingDefaults"];
    NSData* data = [sharedDefaults dataForKey:@"graphs"];
    if(data) {
        self.graphs = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    } else {
        self.graphs = [[NSMutableArray alloc] init];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString* searchString = [searchController.searchBar text];
    SymbolSearch* search = [[SymbolSearch alloc] init];
    [search lookupSymbol:searchString withBlock:^(NSArray* results) {
        self.searchResults = results;
        [((UITableViewController*) self.searchController.searchResultsController).tableView reloadData];
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StockRequest* request = [[StockRequest alloc] init];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [request startRequestWithSymbol:cell.textLabel.text duration:DAY withBlock:^(StockGraph *graph) {
        graph.name = cell.detailTextLabel.text;
        if([self.graphs containsObject:graph]) {
            [(StockGraph*) [self.graphs objectAtIndex:[self.graphs indexOfObject:graph]] updateWithData:graph];
        } else {
            [self.graphs addObject:graph];
        }
        [self saveUserDefaults];
        [self.searchController dismissViewControllerAnimated:YES completion:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
}

-(void)saveUserDefaults {
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.graphs];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.noahstocks.TodayExtensionSharingDefaults"];
    [sharedDefaults setObject:data forKey:@"graphs"];
    [sharedDefaults synchronize];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DefaultCell"];
    }
    NSDictionary* result = [self.searchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = [result objectForKey:@"symbol"];
    cell.detailTextLabel.text = [result objectForKey:@"name"];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}
@end
