//
//  SCMasterViewController.h
//  GradCafe
//
//  Created by Shunji Li on 13-2-11.
//  Copyright (c) 2013年 Shunji Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFHpple.h"
#import "GCResult.h"

@class SCDetailViewController;

@interface SCMasterViewController : UITableViewController<UISearchBarDelegate>

@property (strong, nonatomic) SCDetailViewController *detailViewController;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSString *searchKey;
@end
