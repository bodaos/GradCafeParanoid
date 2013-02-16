//
//  SCMasterViewController.m
//  GradCafe
//
//  Created by Shunji Li on 13-2-11.
//  Copyright (c) 2013年 Shunji Li. All rights reserved.
//

#import "SCMasterViewController.h"

#import "SCDetailViewController.h"

@interface SCMasterViewController ()

@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) NSMutableData *mutableData;
@end

@implementation SCMasterViewController

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    if (searchBar.isFirstResponder) {
        [searchBar resignFirstResponder];
    }
}
#pragma mark SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    _searchKey = [[searchBar text] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *searchURL = [NSString stringWithFormat:@"http://www.thegradcafe.com/survey/index.php?q=%@&pp=250",_searchKey];
    //NSLog([searchBar text]);
    [self loadTutorials:searchURL];
    [searchBar setPlaceholder:_searchKey];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    _searchKey = searchText;
}

#pragma mark Loading data

-(void)loadTutorials:(NSString*) string {

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:string] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];

}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    [_mutableData appendData:data];

}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _mutableData = [[NSMutableData alloc] init];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    TFHpple *resultsParser = [TFHpple hppleWithHTMLData:_mutableData];
    
    
    NSString *resultXpathQueryString = @"//table[@class='results']/tr";
    NSArray *resultsNodes = [resultsParser searchWithXPathQuery:resultXpathQueryString];
    
    
    NSMutableArray *newResults = [[NSMutableArray alloc] initWithCapacity:0];
    for (TFHppleElement *element in resultsNodes) {
        
        GCResult  *result = [[GCResult alloc] initWithUniversity:[[element firstChild] text] andDecision:nil];
        result.field = [[element childAtIndex:1] text];
        result.decision = [[[element childAtIndex:2] childAtIndex:0 ] text];
        result.interaction = [[element childAtIndex:2] text] ;
        [newResults addObject:result];
    }
    if (_refreshHeaderView.state == EGOOPullRefreshLoading) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    
    _objects = newResults;
    [self.tableView reloadData];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                    message:@"You must be connected to the internet to use this app."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    if (_refreshHeaderView.state == EGOOPullRefreshLoading) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    
    _objects = nil;
    [self.tableView reloadData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Master", @"Master");
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.title = @"GradCafe Paranoid";
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshTable:)];
    self.navigationItem.leftBarButtonItem = refreshButton;
    EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    view.delegate = self;
    [self.tableView addSubview:view];
    _refreshHeaderView = view;
}

-(void)viewDidAppear:(BOOL)animated
{
    if (_searchKey) {
        [self loadTutorials:[NSString stringWithFormat:@"http://www.thegradcafe.com/survey/index.php?q=%@&pp=250",_searchKey]];
    }else{
        [self loadTutorials:URL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshTable:(id)sender
{
    if (_searchKey) {
        [self loadTutorials:[NSString stringWithFormat:@"http://www.thegradcafe.com/survey/index.php?q=%@&pp=250",_searchKey]];
    }else{
        [self loadTutorials:URL];
    }

}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count+1;
}

// Customize the appearance of table view cells.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"The row is %d", indexPath.row);
    if (indexPath.row !=0) {
        GCResult *object = _objects[indexPath.row-1];
        cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
        if ([object.decision isEqualToString:@"Accepted"]) {
            cell.detailTextLabel.backgroundColor = [UIColor colorWithRed:152.0/255 green:251.0/255 blue:152.0/255 alpha:0.5];
            //NSLog(@"accepted");
        }
        if ([object.decision isEqualToString:@"Rejected"]) {
            cell.detailTextLabel.backgroundColor = [UIColor colorWithRed:255.0/255 green:182.0/255 blue:193.0/255 alpha:0.5];
            //NSLog(@"accepted");
        }
        cell.detailTextLabel.textColor = [UIColor blackColor];

    }
   
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row == 0) {//[indexPath indexAtPosition:0] == 0 && 
        static NSString *CellIdentifier = @"SearchCell";
        UITableViewCell *searchBarCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        _searchBar = [[UISearchBar alloc] initWithFrame:searchBarCell.frame];
        _searchBar.showsCancelButton = YES;
        _searchBar.delegate = self;
        if (_searchKey) {
            [_searchBar setPlaceholder:_searchKey];
        }
        [searchBarCell addSubview:_searchBar];

        return searchBarCell;
    } // ...
    GCResult *object = _objects[indexPath.row-1];
    cell.textLabel.text = object.university;
    cell.detailTextLabel.text = object.field;
        return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row !=0) {
        if (!self.detailViewController) {
            self.detailViewController = [[SCDetailViewController alloc] initWithNibName:@"SCDetailViewController" bundle:nil];
        }
        GCResult *object = _objects[indexPath.row-1];
        self.detailViewController.detailItem = object;
        [self.navigationController pushViewController:self.detailViewController animated:YES];

    }
    }
#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
-(void) pullRefresh{
 
    if (_searchKey) {
        [self loadTutorials:[NSString stringWithFormat:@"http://www.thegradcafe.com/survey/index.php?q=%@&pp=250",_searchKey]];
    }else{
        [self loadTutorials:URL];
    }
    _reloading = NO;
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self performSelector:@selector(pullRefresh) withObject:nil afterDelay:0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}
@end
