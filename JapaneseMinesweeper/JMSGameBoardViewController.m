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
#import <GameKit/GKLocalPlayer.h>
#import <GameKit/GKScore.h>
#import <GameKit/GKGameCenterViewController.h>
#import "JMSLeaderboardManager.h"
#import "Helpers/JMSSoundHelper.h"
#import "JMSPopoverPresentationController.h"
#import "JMSTutorialManager.h"

@interface JMSGameBoardViewController ()
{
    BOOL initialTapPerformed;
    NSInteger minesCount;
    NSUInteger level;
    BOOL popoverAlreadyDismissed;
    BOOL shouldOpenCellInZeroDirection;
    JMSTutorialManager *tutorialManager;
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

- (BOOL) shouldDisplayTutorial
{
    return YES;
   // return [[[JMSLeaderboardManager alloc] init] rowsCount] == 0;
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

- (void)createTutorialGame
{
    initialTapPerformed = YES;
    [self setScore:0];
    level = [[NSUserDefaults standardUserDefaults] integerForKey:@"level"];
    [self setCellsLeftCount:100 - level];
    minesCount = level;
    [self setCellsMarked:0];
    [self.mineGridView fillTutorialMapWithLevel:level];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([self shouldDisplayTutorial])
    {
        [self createTutorialGame];
        tutorialManager = [[JMSTutorialManager alloc] initWithGameboardController:self];
    }
    else
    {
        if (self.mainViewController.gameSessionInfo)
        {
            [self importFromGameSession];
        }
        else
        {
            [self createNewGame];
        }
    }
    shouldOpenCellInZeroDirection = [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldOpenSafeCells"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view bringSubviewToFront:self.ivSnapshot];
    [self.ivSnapshot setImage:self.mainViewController.mineGridSnapshot];
    [self.ivSnapshot setHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.mineGridView refreshCells];
    [self.ivSnapshot setHidden:YES];
    [self configureUI];
    [self addGestureRecognizers];
    
    if ([self shouldDisplayTutorial] && tutorialManager)
    {
        [tutorialManager moveToNextStep];
    }
    
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
    NSString *caption;
    UIColor *captionColor;
    
    if (self.mineGridView.gameFinished)
    {
        captionColor = [UIColor colorFromInteger:0xffff3300];
        caption = @"PLAY AGAIN";
    }
    else
    {
        captionColor = [UIColor colorFromInteger:0xffa818ff];
        caption = @"RESET GAME";
    }

    [self.btnResetGame setTitleColor:captionColor forState:UIControlStateNormal];
    [self.btnResetGame setTitle:caption forState:UIControlStateNormal];
    
    [self.btnMainMenu.layer setCornerRadius:10];
    [self.btnResetGame.layer setCornerRadius:10];
    [self.btnMainMenu.layer setMasksToBounds:YES];
    [self.btnResetGame.layer setMasksToBounds:YES];
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
    
    if (position.row == NSNotFound || position.column == NSNotFound ||
        ([self shouldDisplayTutorial] && !tutorialManager.isFinished && ![tutorialManager isAllowedWithAction:JMSAllowedActionsClick
                                                                                                     position:position])) return;
    
    if (!initialTapPerformed)
    {
        [self.mineGridView fillMapWithLevel:level exceptPosition:position];
        initialTapPerformed = YES;
    }
    
    if ([self.mineGridView.gameboard mineAtPosition:position])
    {
        [[JMSSoundHelper instance] playSoundWithAction:JMSSoundActionGameFailed];
        [self.mineGridView clickedWithCoordinate:coord];
        [self postScore];
        [self finalizeGame];
        [self.mainViewController setGameSessionInfo:nil];
        [self.mainViewController setMineGridSnapshot:nil];
        return;
    }
    else
    {
        NSUInteger unmarkedCellsCount;
        NSUInteger openedCellsCount;
        BOOL shouldOpenSafeCells = (![self shouldDisplayTutorial] && shouldOpenCellInZeroDirection) ||
                                    ([self shouldDisplayTutorial] && tutorialManager.currentStep >= JMSTutorialStepLastCellClick);
        BOOL opened = [self.mineGridView.gameboard openInZeroDirectionsFromPosition:position
                                                                      unmarkedCount:&unmarkedCellsCount
                                                                        openedCount:&openedCellsCount
                                                                shouldOpenSafeCells:shouldOpenSafeCells];
        if (opened)
        {
            if ([self shouldDisplayTutorial] && !tutorialManager.isFinished)
            {
                [tutorialManager completeTaskWithPosition:position];
            }
        }
        else
        {
            return;
        }
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
            [self showMessageBox];
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
        
        if (position.row == NSNotFound || position.column == NSNotFound ||
            ([self shouldDisplayTutorial] && !tutorialManager.isFinished && ![tutorialManager isAllowedWithAction:JMSAllowedActionsMark
                                                                                                         position:position])) return;
        
        if ([self shouldDisplayTutorial])
        {
            if ([tutorialManager taskCompletedWithPosition:position])
                return;
            else
                [tutorialManager completeTaskWithPosition:position];
        }
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

- (void)showMessageBox
{
    JMSMessageBoxView *alertView = [[JMSMessageBoxView alloc] initWithButtonTitle:@"Play again"
                                                                    actionHandler:^{
                                                                        [self resetGame];
                                                                    }];
    [alertView setContainerView:[self messageBoxContentView]];
    [alertView setUseMotionEffects:true];
    [alertView show];
}

- (UIView *)messageBoxContentView
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    UILabel *lbCaption = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 32)];
    lbCaption.textAlignment = NSTextAlignmentCenter;
    lbCaption.attributedText = [[NSAttributedString alloc] initWithString:@"You won this round"
                                                               attributes:@{
                                                                            NSForegroundColorAttributeName:
                                                                                [UIColor colorFromInteger:0xffff6600],
                                                                            NSFontAttributeName:
                                                                                [UIFont fontWithName:@"HelveticaNeue-Light"
                                                                                                size:28]
                                                                            }];
    
    UILabel *lbText = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 280, 150)];
    lbText.numberOfLines = 0;
    lbText.textAlignment = NSTextAlignmentCenter;

    lbText.attributedText = [[NSAttributedString alloc] initWithString:@"Congratulations!\n\nAll mines were discovered"
                                                            attributes:@{
                                                                         NSForegroundColorAttributeName:
                                                                             [UIColor colorFromInteger:0xffaaaaaa],
                                                                         NSFontAttributeName:
                                                                             [UIFont systemFontOfSize:17]
                                                                         }];
    [contentView addSubview:lbCaption];
    [contentView addSubview:lbText];
   
    return contentView;
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
        self.mainViewController.mineGridSnapshot = [self snapshot:self.mineGridView];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (UIImage *)snapshot:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (BOOL)iOS8OrAbove
{
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare:@"8.0"
                                                                       options:NSNumericSearch];
    return (order == NSOrderedSame || order == NSOrderedDescending);
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return YES;
}

- (IBAction)resetGameClicked
{
    if (!initialTapPerformed)
    {
        return;
    }
    if (self.mineGridView.gameFinished)
    {
        [self resetGame];
        return;
    }
    if ([self iOS8OrAbove])
    {
        
        UIAlertController *resetGameController = [UIAlertController alertControllerWithTitle:nil
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *alertActionYes = [UIAlertAction actionWithTitle:@"Confirm reset" style:UIAlertActionStyleDestructive
                                                               handler:^(UIAlertAction *action) {
                                                                   [self resetGame];
                                                               }];
        [resetGameController addAction:alertActionYes];
        [resetGameController setModalPresentationStyle:UIModalPresentationPopover];
    
        UIPopoverPresentationController *popPresenter = [resetGameController popoverPresentationController];
        popPresenter.sourceView = self.btnResetGame;
        popPresenter.sourceRect = self.btnResetGame.bounds;
        popPresenter.delegate = self;
        [self presentViewController:resetGameController animated:YES completion:nil];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                                        cancelButtonTitle:@"" destructiveButtonTitle:@"Confirm reset"
                                                        otherButtonTitles:nil];
        [actionSheet showFromRect:self.btnResetGame.frame inView:self.view animated:NO];
        
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self resetGame];
    }
}

- (void)resetGame
{
    [self.mineGridView resetGame];
    [self.mainViewController setGameSessionInfo:nil];
    [self.mainViewController setMineGridSnapshot:nil];
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
