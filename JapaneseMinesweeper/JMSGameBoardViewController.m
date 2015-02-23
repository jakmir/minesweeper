//
//  GameBoardViewController.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "JMSGameBoardViewController.h"
#import "JMSMineGridCell.h"
#import "JMSMainViewController.h"
#import "Classes/JMSGameSessionInfo.h"
#import "UIColor+ColorFromHexString.h"
#import "JMSAlertViewController.h"
#import <GameKit/GKLocalPlayer.h>
#import <GameKit/GKScore.h>
#import <GameKit/GKGameCenterViewController.h>
#import "JMSLeaderboardManager.h"
#import "Helpers/JMSSoundHelper.h"

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
    [self.btnMainMenu drawGradientWithStartColor:[UIColor colorFromInteger:0xffe9e9e9]
                                  andFinishColor:[UIColor colorFromInteger:0xffcccccc]];
    
    UIColor *startColor;
    UIColor *endColor;
    NSString *caption;
    UIColor *captionColor;
    
    if (self.mineGridView.gameFinished)
    {
        startColor = [UIColor colorFromInteger:0xffafafaf];
        endColor =[UIColor colorFromInteger:0xffcccccc];
        captionColor = [UIColor colorFromInteger:0xffff3300];
        caption = @"PLAY AGAIN";
    }
    else
    {
        startColor = [UIColor colorFromInteger:0xffe9e9e9];
        endColor = [UIColor colorFromInteger:0xffcccccc];
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
    
    if (self.mineGridView.gameFinished) return;
    
    CGPoint coord = [gestureRecognizer locationInView:self.mineGridView];
    
    struct JMSPosition position = [self.mineGridView cellPositionWithCoordinateInside:coord];
    
    if (position.row == NSNotFound || position.column == NSNotFound) return;
    
    if (!initialTapPerformed)
    {
        [self.mineGridView fillMapWithLevel:level exceptPosition:position];
        initialTapPerformed = YES;
    }
    
    if ([self.mineGridView.gameboard mineAtPosition:position])
    {
        [self.mineGridView clickedWithCoordinate:coord];
        [[JMSSoundHelper instance] playSoundWithAction:JMSSoundActionGameFailed];
        [self postScore];
        [self finalizeGame];
        [self.mainViewController setGameSessionInfo:nil];
        return;
    }
    else
    {
        NSUInteger unmarkedCellsCount;
        NSUInteger openedCellsCount;
        BOOL opened = [self.mineGridView.gameboard openInZeroDirectionsFromPosition:position
                                                                      unmarkedCount:&unmarkedCellsCount
                                                                        openedCount:&openedCellsCount];
        if (!opened) return;

        self.cellsLeftCount = [self.mineGridView cellsLeftToOpen];
        self.score += [self scoreToAddFromPosition:position];
        self.score += [self vanillaScore] * (openedCellsCount - 1);
        self.cellsMarked -= unmarkedCellsCount;
           
        if (self.cellsLeftCount > 0)
        {
            [[JMSSoundHelper instance] playSoundWithAction:JMSSoundActionCellTap];
        }
        else
        {
            [[JMSSoundHelper instance] playSoundWithAction:JMSSoundActionLevelCompleted];
            self.score *= [self levelModifier];
            [self postScore];
            self.cellsMarked += [self.mineGridView markMines];
            [self finalizeGame];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Congratulations"
                                                                message:@"You won this round"
                                                                delegate:self
                                                       cancelButtonTitle:@"Play again"
                                                       otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (CGFloat)levelModifier
{
    return 1 + level / 100.0;
}

- (CGFloat)vanillaScore
{
    return baseScore * pow([self levelModifier], 4);
}

- (CGFloat)scoreToAddFromPosition:(struct JMSPosition)position
{
    return [self vanillaScore] * pow(1 + [self.mineGridView bonus:position], 3);
}

- (void) longTap: (UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    if (self.mineGridView.gameFinished) return;
    
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
            [[JMSSoundHelper instance] playSoundWithAction:JMSSoundActionPutFlag];
        }
        if (oldState == MineGridCellStateClosed && newState == MineGridCellStateMarked)
        {
            self.cellsMarked++;
            [[JMSSoundHelper instance] playSoundWithAction:JMSSoundActionPutFlag];
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
    CGFloat progress = (100.0 - level - self.cellsLeftCount) / (100-level);
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

@end
