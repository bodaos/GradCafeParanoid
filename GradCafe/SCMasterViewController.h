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

@interface SCMasterViewController : UITableViewController

@property (strong, nonatomic) SCDetailViewController *detailViewController;

@end
