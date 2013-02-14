//
//  SCDetailViewController.m
//  GradCafe
//
//  Created by Shunji Li on 13-2-11.
//  Copyright (c) 2013年 Shunji Li. All rights reserved.
//

#import "SCDetailViewController.h"
#import "GCResult.h"
@interface SCDetailViewController ()
- (void)configureView;
@end

@implementation SCDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        GCResult *result = self.detailItem;
        self.detailDescriptionLabel.text = [result university];
        self.decisionLabel.text = [result decision];
        self.interactionLabel.text = [result interaction];
        self.fieldLabel.text = [result field];
        
    }
    if ([self.decisionLabel.text isEqualToString:@"Accepted"]) {
        self.view.backgroundColor = [UIColor colorWithRed:0.9 green:1.0 blue:0.9 alpha:1.0];
    }
    if ([self.decisionLabel.text isEqualToString:@"Rejected"]) {
        self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1.0];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Details";
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}
							
@end
