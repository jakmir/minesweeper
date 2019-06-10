//
//  JMSLeaderboardTableViewController.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/16/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSLeaderboardViewController.h"
#import "JMSScoreTableViewCell.h"
#import "JMSLeaderboardManager.h"
#import "JMSGameSessionModel.h"
#import "UIColor+ColorFromHexString.h"
#import "JMSLeaderboardView.h"

static const CGFloat kLeaderboardTableHeaderHeight = 22;
static NSString *kScoreCellId = @"ScoreCell";
static NSString *kScoreHeaderId = @"ScoreHeader";

@interface JMSLeaderboardViewController() <UITableViewDataSource, UITableViewDelegate, GKGameCenterControllerDelegate>

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong, readonly) JMSLeaderboardView *leaderboardView;

@end

@implementation JMSLeaderboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [[[JMSLeaderboardManager alloc] init] highScoreList];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSString *)leaderboardName {
    return @"JMSMainLeaderboard";
}

#pragma mark - Access Properties

- (JMSLeaderboardView *)leaderboardView {
    if ([self.view isKindOfClass:[JMSLeaderboardView class]]) {
        return (JMSLeaderboardView *)self.view;
    }
    return nil;
}

- (void)setDataSource:(NSArray *)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.leaderboardView fillWithModel:dataSource];
        });
    }
}

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [tableView dequeueReusableCellWithIdentifier:kScoreHeaderId];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return kLeaderboardTableHeaderHeight;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
            cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    JMSScoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kScoreCellId
                                                                  forIndexPath:indexPath];
    JMSGameSessionModel *gameSession = self.dataSource[indexPath.row];
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

#pragma mark - Game Center-related actions

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
