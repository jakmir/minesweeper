//
//  JMSLeaderboardTableViewController.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/16/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GKGameCenterViewController.h>
#import "JMSGradientButton.h"

@interface JMSLeaderboardTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, GKGameCenterControllerDelegate>

- (IBAction)back;
- (IBAction)openGameboardScreen;

@property (weak, nonatomic) IBOutlet UIButton *btnShowGameCenterScreen;
@property (weak, nonatomic) IBOutlet UIButton *btnBackToMainMenu;
@property (weak, nonatomic) IBOutlet UILabel *lbEmptyRemark;

@end
