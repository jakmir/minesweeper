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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self drawGradients];
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
    CGFloat height = 22;
    CGFloat width = CGRectGetWidth(tableView.frame);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *lbLevelCaption = [[UILabel alloc] initWithFrame:CGRectMake(width * 0.04, 0, width * 0.3, height)];
    lbLevelCaption.attributedText = [[NSAttributedString alloc] initWithString:@"Level"
                                                                    attributes:@{
                                                                                 NSForegroundColorAttributeName:
                                                                                     [UIColor darkGrayColor],
                                                                                 NSFontAttributeName:
                                                                                     [UIFont systemFontOfSize:17]
                                                                                 }];
    UILabel *lbProgressCaption = [[UILabel alloc] initWithFrame:CGRectMake(width * 0.34, 0, width * 0.34, height)];
    lbProgressCaption.attributedText = [[NSAttributedString alloc] initWithString:@"Progress"
                                                                       attributes:@{
                                                                                 NSForegroundColorAttributeName:
                                                                                     [UIColor darkGrayColor],
                                                                                 NSFontAttributeName:
                                                                                     [UIFont systemFontOfSize:17]
                                                                                 }];

    UILabel *lbScoreCaption = [[UILabel alloc] initWithFrame:CGRectMake(width * 0.68, 0, width * 0.25, height)];
    lbScoreCaption.textAlignment = NSTextAlignmentRight;
    lbScoreCaption.attributedText = [[NSAttributedString alloc] initWithString:@"Score"
                                                                    attributes:@{
                                                                                 NSForegroundColorAttributeName:
                                                                                     [UIColor darkGrayColor],
                                                                                 NSFontAttributeName:
                                                                                     [UIFont systemFontOfSize:17]
                                                                                 }];
    [view addSubview:lbScoreCaption];
    [view addSubview:lbLevelCaption];
    [view addSubview:lbProgressCaption];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMSScoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScoreCell" forIndexPath:indexPath];
    JMSGameSession *gameSession = dataSource[indexPath.row];
    cell.lbScore.text = [gameSession.score stringValue];
    cell.lbLevel.text = [gameSession.level stringValue];
    
    NSUInteger progress = lroundf(gameSession.progress.floatValue * 100);
    cell.lbProgress.text = [NSString stringWithFormat:@"%d%%", progress];
    cell.lbProgress.textColor = progress == 100 ? [UIColor colorFromInteger:0xff009900] : [UIColor colorFromInteger:0xffff7f00];
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

#pragma mark - UI improvement methods

- (void)drawGradients
{
    [self.btnBackToMainMenu drawGradientWithStartColor:[UIColor colorFromInteger:0xffe9e9e9]
                                        andFinishColor:[UIColor colorFromInteger:0xffcccccc]];
    [self.btnShowGameCenterScreen drawGradientWithStartColor:[UIColor colorFromInteger:0xffe9e9e9]
                                              andFinishColor:[UIColor colorFromInteger:0xffcccccc]];
}
@end
