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
#import "JMSSoundManager.h"

@interface JMSGameBoardViewController ()
{
    BOOL initialTapPerformed;
    NSInteger minesCount;
    NSUInteger level;
    
    JMSSoundManager *soundManager;
}

@property (nonatomic) CGFloat score;
@property (nonatomic) NSInteger cellsLeftCount;
@property (nonatomic) NSInteger cellsMarked;

@end

const CGFloat baseScore = 175;

@implementation JMSGameBoardViewController

- (void)addGestureRecognizers
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(singleTap:)];
    [self.mineGridView addGestureRecognizer:tapRecognizer];

    UILongPressGestureRecognizer *longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                    action:@selector(longTap:)];
    CGFloat minimumPressDuration = [[NSUserDefaults standardUserDefaults] floatForKey:@"holdDuration"];
    longTapRecognizer.minimumPressDuration = minimumPressDuration;
    [self.mineGridView addGestureRecognizer:longTapRecognizer];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)importFromGameSession
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

- (void)createNewGame
{
    initialTapPerformed = NO;
    [self setScore:0];
    level = [[NSUserDefaults standardUserDefaults] integerForKey:@"level"];
    [self setCellsLeftCount:100 - level];
    minesCount = level;
    [self setCellsMarked:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.mainViewController.gameSessionInfo)
    {
        [self importFromGameSession];
    }
    else
    {
        [self createNewGame];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    soundManager = [[JMSSoundManager alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configureUI];
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

- (void) configureUI
{
    [self updateMenu];
    UIColor *patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper"]];
    [self.resultsView setBackgroundColor:patternColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeGestureRecognizers];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gameboard control methods

- (void)finalizeGame
{
    [self.mineGridView finalizeGame];
    [self updateMenu];
}

- (void) updateMenu
{
    [self.btnMainMenu drawGradientWithStartColor:[UIColor colorFromInteger:0x1f9f9f9f]
                                  andFinishColor:[UIColor colorFromInteger:0xffcfcfcf]];
    
    UIColor *startColor;
    UIColor *endColor;
    NSString *caption;
    UIColor *captionColor;
    
    if (self.mineGridView.gameFinished)
    {
        startColor = [UIColor colorFromInteger:0x1f7f7f7f];
        endColor =[UIColor colorFromInteger:0xffaaaaaa];
        captionColor = [UIColor colorFromInteger:0xffff3300];
        caption = @"PLAY AGAIN";
    }
    else
    {
        startColor = [UIColor colorFromInteger:0x1f9f9f9f];
        endColor = [UIColor colorFromInteger:0xffcfcfcf];
        captionColor = [UIColor colorFromInteger:0xffa818ff];
        caption = @"RESET GAME";
        
    }
    [self.btnResetGame drawGradientWithStartColor:startColor
                                   andFinishColor:endColor];
    [self.btnResetGame setTitleColor:captionColor forState:UIControlStateNormal];
    [self.btnResetGame setTitle:caption forState:UIControlStateNormal];
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
        [soundManager playSoundAction:JMSSoundActionGameFailed];
        [self postScore];
        [self finalizeGame];
        [self.mainViewController setGameSessionInfo:nil];
    }
    else
    {
        [soundManager playSoundAction:JMSSoundActionCellTap];
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
            self.cellsMarked += [self.mineGridView markUncoveredMines];
            [soundManager playSoundAction:JMSSoundActionLevelCompleted];
            self.score *= (1 + level / 100.0);
            [self postScore];
            [self finalizeGame];
            [self showVictoryScreen];
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

    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Upper Menu Actions

- (IBAction)backToMainMenu
{
    if (initialTapPerformed && !self.mineGridView.gameFinished)
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
    [self.mineGridView resetGame];
    [self.mainViewController setGameSessionInfo:nil];
    [self createNewGame];
    [self updateMenu];    
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
    [[[JMSLeaderboardManager alloc] init] postGameScore:lroundf(self.score)
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

#pragma mark - Dialogs and alerts

- (void)showVictoryScreen
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"You won this round" delegate:self
                                              cancelButtonTitle:@"Play again" otherButtonTitles:nil];
    [alertView show];
}

@end
