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

static const CGFloat kLeaderboardTableHeaderHeight = 22;

@interface JMSLeaderboardTableViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation JMSLeaderboardTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dataSource = [[[JMSLeaderboardManager alloc] init] highScoreList];
    self.lbEmptyRemark.hidden = self.dataSource.count > 0;
    
    CGFloat cornerRadius = [[JMSKeyValueSettingsHelper instance] buttonCornerRadius];
    [self.btnBackToMainMenu.layer setCornerRadius:cornerRadius];
    [self.btnShowGameCenterScreen.layer setCornerRadius:cornerRadius];
    [self.btnBackToMainMenu.layer setMasksToBounds:YES];
    [self.btnShowGameCenterScreen.layer setMasksToBounds:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (CGFloat)headerHeight {
    return kLeaderboardTableHeaderHeight;
}

- (NSString *)leaderboardName {
    return @"JMSMainLeaderboard";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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
    lbLevelCaption.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Level", @"Level: table column header")
                                                                    attributes:attrs];
    UILabel *lbProgressCaption = [[UILabel alloc] initWithFrame:CGRectMake(width * waypoints[1], 0, width * (waypoints[2] - waypoints[1]), height)];
    lbProgressCaption.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Progress", @"Progress: table column header")
                                                                       attributes:attrs];

    UILabel *lbScoreCaption = [[UILabel alloc] initWithFrame:CGRectMake(width * waypoints[2], 0, width * (waypoints[3] - waypoints[2]), height)];
    lbScoreCaption.textAlignment = NSTextAlignmentRight;
    lbScoreCaption.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Score", @"Score: table column header")
                                                                    attributes:attrs];
    [view addSubview:lbScoreCaption];
    [view addSubview:lbLevelCaption];
    [view addSubview:lbProgressCaption];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JMSScoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScoreCell" forIndexPath:indexPath];
    JMSGameSession *gameSession = self.dataSource[indexPath.row];
    [cell fillWithModel:gameSession];

    return cell;
}

#pragma mark - Button actions

- (IBAction)back {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)openGameboardScreen {
    [self showLeaderboard:[self leaderboardName]];
}

#pragma mark - GameCenter-related actions

- (void)showLeaderboard:(NSString *)leaderboardId {
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController == nil) {
        return;
    }
    gameCenterController.gameCenterDelegate = self;
    gameCenterController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gameCenterController.leaderboardIdentifier = leaderboardId;
    [self presentViewController:gameCenterController animated:YES completion:nil];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController dismissViewControllerAnimated:NO completion:nil];
}

@end
