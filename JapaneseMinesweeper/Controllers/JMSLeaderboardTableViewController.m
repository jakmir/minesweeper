//
//  JMSLeaderboardTableViewController.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/16/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSLeaderboardTableViewController.h"
#import "JMSScoreTableViewCell.h"
#import "JMSLeaderboardManager.h"
#import "JMSGameSession.h"
#import "UIColor+ColorFromHexString.h"

@interface JMSLeaderboardTableViewController ()
{
    NSArray *dataSource;
}
@end

@implementation JMSLeaderboardTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataSource = [[[JMSLeaderboardManager alloc] init] highScoreList];
    self.lbEmptyRemark.hidden = dataSource.count > 0;
    
    CGFloat cornerRadius = [[JMSKeyValueSettingsHelper instance] buttonCornerRadius];
    [self.btnBackToMainMenu.layer setCornerRadius:cornerRadius];
    [self.btnShowGameCenterScreen.layer setCornerRadius:cornerRadius];
    [self.btnBackToMainMenu.layer setMasksToBounds:YES];
    [self.btnShowGameCenterScreen.layer setMasksToBounds:YES];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)headerHeight {
    return 22.0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat height = [self headerHeight];
    CGFloat width = CGRectGetWidth(tableView.frame);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    view.backgroundColor = [UIColor whiteColor];
    
    float waypoints[] = {0.04, 0.34, 0.68, 0.93};
    UILabel *lbLevelCaption = [[UILabel alloc] initWithFrame:CGRectMake(width * waypoints[0], 0, width * (waypoints[1] - waypoints[0]), height)];
    NSDictionary *attrs = @{
                            NSForegroundColorAttributeName:
                                [UIColor darkGrayColor],
                            NSFontAttributeName:
                                [UIFont systemFontOfSize:17]
                            };
    lbLevelCaption.attributedText = [[NSAttributedString alloc] initWithString:@"Level"
                                                                    attributes:attrs];
    UILabel *lbProgressCaption = [[UILabel alloc] initWithFrame:CGRectMake(width * waypoints[1], 0, width * (waypoints[2] - waypoints[1]), height)];
    lbProgressCaption.attributedText = [[NSAttributedString alloc] initWithString:@"Progress"
                                                                       attributes:attrs];

    UILabel *lbScoreCaption = [[UILabel alloc] initWithFrame:CGRectMake(width * waypoints[2], 0, width * (waypoints[3] - waypoints[2]), height)];
    lbScoreCaption.textAlignment = NSTextAlignmentRight;
    lbScoreCaption.attributedText = [[NSAttributedString alloc] initWithString:@"Score"
                                                                    attributes:attrs];
    [view addSubview:lbScoreCaption];
    [view addSubview:lbLevelCaption];
    [view addSubview:lbProgressCaption];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMSScoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScoreCell" forIndexPath:indexPath];
    JMSGameSession *gameSession = dataSource[indexPath.row];
    [cell assignScore:[gameSession.score intValue]
             progress:lroundf(gameSession.progress.floatValue * 100)
                level:[gameSession.level intValue]];
    return cell;
}

#pragma mark - Button actions

- (IBAction)back
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)openGameboardScreen
{
    [self showLeaderboard:@"JMSMainLeaderboard"];
}

#pragma mark - GameCenter-related actions

- (void) showLeaderboard: (NSString *)leaderboardId
{
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gameCenterController.leaderboardIdentifier = leaderboardId;
        [self presentViewController:gameCenterController animated:YES completion:nil];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:NO completion:nil];
}

@end
