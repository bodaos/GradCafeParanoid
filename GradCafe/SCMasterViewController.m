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
@synthesize searchBar = _searchBar ;

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    NSString *searchURL = [NSString stringWithFormat:@"http://www.thegradcafe.com/survey/index.php?q=%@", [searchBar text]];
    NSLog([searchBar text]);
    [self loadTutorials:searchURL];
}

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
        NSLog(@"%@", result.interaction );
        [newResults addObject:result];
        count += 1;
    }
  
    //NSLog(@"%i", count);
    _objects = newResults;
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
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshTable:)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    [self loadTutorials: @"http://www.thegradcafe.com/survey/"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshTable:(id)sender
{
    if ([_searchBar text]) {
        [self loadTutorials:[NSString stringWithFormat:@"http://www.thegradcafe.com/survey/index.php?q=%@", [_searchBar text]]];
    }else{
        [self loadTutorials:@"http://www.thegradcafe.com/survey/"];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row == 0) {//[indexPath indexAtPosition:0] == 0 && 
        static NSString *CellIdentifier = @"SearchCell";
        UITableViewCell *searchBarCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        _searchBar = [[UISearchBar alloc] initWithFrame:searchBarCell.frame];
        _searchBar.showsCancelButton = YES;
        _searchBar.delegate = self;
        [searchBarCell addSubview:_searchBar];
        return searchBarCell;
    } // ...
        GCResult *object = _objects[indexPath.row-1];
        cell.textLabel.text = object.university;
    

    
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

    if (!self.detailViewController) {
        self.detailViewController = [[SCDetailViewController alloc] initWithNibName:@"SCDetailViewController" bundle:nil];
    }
    NSDate *object = _objects[indexPath.row-1];
    self.detailViewController.detailItem = object;
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
