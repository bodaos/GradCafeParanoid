//
//  SCMasterViewController.m
//  GradCafe
//
//  Created by Shunji Li on 13-2-11.
//  Copyright (c) 2013年 Shunji Li. All rights reserved.
//

#import "SCMasterViewController.h"

#import "SCDetailViewController.h"

@interface SCMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation SCMasterViewController
@synthesize searchBar = _searchBar, searchKey = _searchKey;
@synthesize refreshHeaderView = _refreshHeaderView;

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    if (searchBar.isFirstResponder) {
        [searchBar resignFirstResponder];
    }
}
#pragma mark SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    _searchKey = [[searchBar text] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *searchURL = [NSString stringWithFormat:@"http://www.thegradcafe.com/survey/index.php?q=%@",_searchKey];
    //NSLog([searchBar text]);
    [self loadTutorials:searchURL];
    [searchBar setPlaceholder:_searchKey];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    _searchKey = searchText;
}

#pragma mark Loading data

-(void)loadTutorials:(NSString*) string {

    int count =0;
    NSURL *url = [NSURL URLWithString:string];
    NSData *resultsHtmlData = [NSData dataWithContentsOfURL:url];
     //NSLog([NSString stringWithUTF8String:[resultsHtmlData bytes] ] );

    TFHpple *resultsParser = [TFHpple hppleWithHTMLData:resultsHtmlData];
    

    NSString *resultXpathQueryString = @"//table[@class='results']/tr";
    NSArray *resultsNodes = [resultsParser searchWithXPathQuery:resultXpathQueryString];
    

    NSMutableArray *newResults = [[NSMutableArray alloc] initWithCapacity:0];
    for (TFHppleElement *element in resultsNodes) {

       GCResult  *result = [[GCResult alloc] initWithUniversity:[[element firstChild] text] andDecision:nil];
        result.field = [[element childAtIndex:1] text];
        result.decision = [[[element childAtIndex:2] childAtIndex:0 ] text];
        result.interaction = [[element childAtIndex:2] text] ;
        //NSLog(@"%@", result.interaction );
        [newResults addObject:result];
        count += 1;
    }
  
    //NSLog(@"%i", count);
    _objects = newResults;
   
    
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
    [self loadTutorials: @"http://www.thegradcafe.com/survey/"];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshTable:(id)sender
{
    if (_searchKey) {
        [self loadTutorials:[NSString stringWithFormat:@"http://www.thegradcafe.com/survey/index.php?q=%@",_searchKey]];
         [self.tableView reloadData];
    }else{
        [self loadTutorials:@"http://www.thegradcafe.com/survey/"];
        [self.tableView reloadData];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
        [self loadTutorials:[NSString stringWithFormat:@"http://www.thegradcafe.com/survey/index.php?q=%@",_searchKey]];
    }else{
        [self loadTutorials:@"http://www.thegradcafe.com/survey/"];
    }
    reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [self.tableView reloadData];
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self performSelector:@selector(pullRefresh) withObject:nil afterDelay:0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}
@end
