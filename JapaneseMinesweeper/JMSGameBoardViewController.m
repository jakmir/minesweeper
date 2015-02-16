//
//  GameBoardViewController.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "JMSGameBoardViewController.h"
#import "JMSMineGridCell.h"
#import "MainViewController.h"
#import "Classes/JMSGameSessionInfo.h"
#import "UIColor+ColorFromHexString.h"
#import "UIImage+ImageEffects.h"
#import "JMSAlertViewController.h"
#import <GameKit/GKLocalPlayer.h>
#import <GameKit/GKScore.h>
#import <GameKit/GKGameCenterViewController.h>
#import "JMSLeaderboardManager.h"
@interface JMSGameBoardViewController ()
{
    BOOL initialTapPerformed;
    NSInteger minesCount;
    NSUInteger level;
}

@property (nonatomic) CGFloat score;
@property (nonatomic) NSInteger cellsLeftCount;
@property (nonatomic) NSInteger cellsMarked;

@end

const CGFloat baseScore = 175;

@implementation JMSGameBoardViewController

- (void)addGestureRecognizers
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.mineGridView addGestureRecognizer:tapRecognizer];

    UILongPressGestureRecognizer *longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    CGFloat minimumPressDuration = [[NSUserDefaults standardUserDefaults] floatForKey:@"holdDuration"];
    longTapRecognizer.minimumPressDuration = minimumPressDuration;
    [self.mineGridView addGestureRecognizer:longTapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.mainViewController.gameSessionInfo)
    {
        initialTapPerformed = YES;
        
        JMSGameSessionInfo *gameSessionInfo = self.mainViewController.gameSessionInfo;
        [self setScore:gameSessionInfo.score];
        level = gameSessionInfo.level;
        [self.mineGridView importMap:gameSessionInfo.map];
        [self setCellsLeftCount:self.mineGridView.cellsLeftToOpen];
        minesCount = level;
        [self setCellsMarked:gameSessionInfo.markedCellsCount];
    }
    else
    {
        initialTapPerformed = NO;
        [self setScore:0];
        level = [[NSUserDefaults standardUserDefaults] integerForKey:@"level"];
        [self setCellsLeftCount:100 - level];
        minesCount = level;
        [self setCellsMarked:0];
    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self drawGradients];
    [self.mineGridView refreshCells];    
    [self addGestureRecognizers];
   
}

- (void)removeGestureRecognizers
{
    [self.mineGridView.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIGestureRecognizer *gr = obj;
        [self.mineGridView removeGestureRecognizer:gr];
    }];
}

- (void) drawGradients
{
    [self.scoreView drawGradientWithStartColor:[UIColor colorFromInteger:0xffe7e7e7]
                                andFinishColor:[UIColor colorFromInteger:0xfff0f0f0]];
    [self.markedMinesCountView drawGradientWithStartColor:[UIColor colorFromInteger:0xffe7e7e7]
                                           andFinishColor:[UIColor colorFromInteger:0xfff0f0f0]];
    [self.cellsCountView drawGradientWithStartColor:[UIColor colorFromInteger:0xffe7e7e7]
                                     andFinishColor:[UIColor colorFromInteger:0xfff0f0f0]];
    [self.btnMainMenu drawGradientWithStartColor:[UIColor colorFromInteger:0x1fcfcfcf] andFinishColor:[UIColor colorFromInteger:0x1fbfbfbf]];
    [self.btnLeaderboards drawGradientWithStartColor:[UIColor colorFromInteger:0x1fcfcfcf] andFinishColor:[UIColor colorFromInteger:0x1fbfbfbf]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeGestureRecognizers];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

#pragma mark - synchronize labels with real values

- (void) setScore:(CGFloat)score
{
    _score = score;

    [self.lbScore setText:[@(lroundf(score)) stringValue]];
}

- (void) setCellsLeftCount:(NSInteger)cellsLeftCount
{
    _cellsLeftCount = cellsLeftCount;
    CGFloat progress = 100 * (100.0 - level - self.cellsLeftCount) / (100 - level);
    [self.lbProgress setText:[NSString stringWithFormat:@"%ld%%", lroundf(progress)]];
}

- (void) setCellsMarked:(NSInteger)cellsMarked
{
    _cellsMarked = cellsMarked;
    
    NSString *stringToDisplay = [NSString stringWithFormat:@"%ld/%ld", (long)cellsMarked, (long)minesCount];
    NSUInteger len = [@(cellsMarked) stringValue].length;
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:stringToDisplay];
    
    UIColor *cellsMarkedColor = cellsMarked > minesCount ? [UIColor colorFromInteger:0xffff7f7f] : [UIColor darkGrayColor];
    [string addAttribute:NSForegroundColorAttributeName value:cellsMarkedColor range:NSMakeRange(0, len)];

    self.lbCellsMarked.attributedText = string;
}

-(UIImage *)blurredSnapshot
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.view drawViewHierarchyInRect:self.view.frame afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
    UIGraphicsEndImageContext();
    return blurredSnapshotImage;
}

#pragma mark - handle taps

- (void) singleTap: (UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    
    CGPoint coord = [gestureRecognizer locationInView:self.mineGridView];
    
    struct JMSPosition position = [self.mineGridView cellPositionWithCoordinateInside:coord];
    
    if (position.row == NSNotFound || position.column == NSNotFound) return;
    
    if (!initialTapPerformed)
    {
        [self.mineGridView fillMapWithLevel:level exceptPosition:position];
        initialTapPerformed = YES;
    }
    
    JMSMineGridCellState oldState = [self.mineGridView cellState:position];
    BOOL mine = [self.mineGridView clickedWithCoordinate:coord];
    JMSMineGridCellState newState = [self.mineGridView cellState:position];
    
    if (mine)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Lost"
                                                                  message:@"There was a mine in that cell."
                                                           preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *submitAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction *action) {
                                                                     [self postScore];
                                                                 }];
        [alertController addAction:submitAction];

        [self presentViewController:alertController animated:YES completion:nil];
        /*
        UIImageView *iv = [[UIImageView alloc] initWithFrame:self.view.frame];
        iv.image = [self blurredSnapshot];
        [self.view addSubview:iv];
        [self.view bringSubviewToFront:iv];
         */
    }
    else
    {
        self.cellsLeftCount = [self.mineGridView cellsLeftToOpen];
        
        //just opened the cell, not possible to do that twice.
        if (oldState != MineGridCellStateOpened && newState == MineGridCellStateOpened)
        {
            if (oldState == MineGridCellStateMarked)
            {
                self.cellsMarked--;
            }

            self.score += baseScore * pow(1 + level / 100.0, 3) * pow(1 + [self.mineGridView bonus:position], 3);
        }
        
        if (self.cellsLeftCount == 0)
        {
            self.score *= (1 + level / 100.0);
            [self postScore];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"You won this round" delegate:self
                                                      cancelButtonTitle:@"Play again" otherButtonTitles:nil];
            [alertView show];

        }
    }
}

- (void) longTap: (UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint coord = [gestureRecognizer locationInView:self.mineGridView];
        struct JMSPosition position = [self.mineGridView cellPositionWithCoordinateInside:coord];
        
        if (position.row == NSNotFound || position.column == NSNotFound) return;
        
        JMSMineGridCellState oldState = [self.mineGridView cellState:position];
        [self.mineGridView longTappedWithCoordinate:coord];
        JMSMineGridCellState newState = [self.mineGridView cellState:position];
        
        if (oldState == MineGridCellStateMarked && newState == MineGridCellStateClosed)
        {
            self.cellsMarked--;
        }
        if (oldState == MineGridCellStateClosed && newState == MineGridCellStateMarked)
        {
            self.cellsMarked++;
        }
    }
}

#pragma mark - alerts

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.mainViewController setGameSessionInfo:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Upper Menu Actions

- (IBAction)backToMainMenu
{
    if (initialTapPerformed)
    {
        JMSGameSessionInfo *gameSessionInfo = [JMSGameSessionInfo new];
        gameSessionInfo.map = [self.mineGridView exportMap];
        gameSessionInfo.score = self.score;
        gameSessionInfo.level = level;
        self.mainViewController.gameSessionInfo = gameSessionInfo;
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)resetGame
{
}

#pragma mark - Submit results 

- (void)postScore
{
    [self postScoreLocally];
    if ([[GKLocalPlayer localPlayer] isAuthenticated])
    {
        [self postScoreToGameCenter];
    }
}
- (void)postScoreLocally
{
    CGFloat progress = (100.0-level-self.cellsLeftCount) / (100-level);
    [[[JMSLeaderboardManager alloc] init] postGameScore:self.score
                                                  level:level
                                               progress:progress];
}

- (void)postScoreToGameCenter
{
    // Report the high score to Game Center
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:@"JMSMainLeaderboard"
                                                                     player:[GKLocalPlayer localPlayer]];
    scoreReporter.value = lroundf(self.score);

    [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError *error) {
        if (error)
        {
            NSLog(@"Failed to report score. Reason is: %@", error.localizedDescription);
        }
        else
        {
            NSLog(@"Reported score successfully");
        }
    }];
}

@end
