//
//  SCDetailViewController.h
//  GradCafe
//
//  Created by Shunji Li on 13-2-11.
//  Copyright (c) 2013年 Shunji Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *decisionLabel;
@property (strong, nonatomic) IBOutlet UILabel *interactionLabel;
@property (strong, nonatomic) IBOutlet UILabel *fieldLabel;
@end
