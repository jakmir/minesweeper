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
#import "JMSGameModel.h"
#import "JMSAlteredCellInfo.h"
#import "UIColor+ColorFromHexString.h"
#import <GameKit/GKLocalPlayer.h>
#import <GameKit/GKScore.h>
#import <GameKit/GKGameCenterViewController.h>
#import "JMSLeaderboardManager.h"
#import "JMSSoundHelper.h"
#import "JMSPopoverPresentationController.h"
#import "JMSTutorialManager.h"
#import "JMSGameboardView.h"
#import "JMSMessageBoxView+LevelCompleted.h"
#import "JMSGameModel+Tutorial.h"

@interface JMSGameBoardViewController ()

@property (nonatomic, readonly) JMSGameboardView *gameboardView;
@property (nonatomic, readonly) JMSTutorialManager *tutorialManager;
@property (nonatomic) BOOL shouldOpenCellInZeroDirection;
@property (nonatomic) BOOL initialTapPerformed;

@end

@implementation JMSGameBoardViewController

- (JMSGameboardView *)gameboardView {
    if ([self.view isKindOfClass:[JMSGameboardView class]]) {
        return (JMSGameboardView *)self.view;
    }
    return nil;
}

- (void)addGestureRecognizers {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(singleTap:)];
    [self.gameboardView.mineGridView addGestureRecognizer:tapRecognizer];

    UILongPressGestureRecognizer *longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                    action:@selector(longTap:)];
    CGFloat minimumPressDuration = [[NSUserDefaults standardUserDefaults] floatForKey:@"holdDuration"];
    longTapRecognizer.minimumPressDuration = minimumPressDuration;
    [self.gameboardView.mineGridView addGestureRecognizer:longTapRecognizer];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldDisplayTutorial {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldLaunchTutorial"];
}

- (void)importFromGameSession {
    self.initialTapPerformed = YES;
    
    JMSGameModel *gameSessionInfo = self.mainViewController.gameModel;
    [gameSessionInfo registerObserver:self];
    
    [self.gameboardView.mineGridView importFromGameboardMap:gameSessionInfo.map];
    [self.gameboardView fillWithModel:gameSessionInfo];
}

- (void)createNewGame {
    self.initialTapPerformed = NO;
    
    NSUInteger level = [[NSUserDefaults standardUserDefaults] integerForKey:@"level"];
    NSArray *map = [self.gameboardView.mineGridView exportMap];
    JMSGameModel *gameModel = [[JMSGameModel alloc] initWithLevel:level map:map];
    [gameModel registerObserver:self];
    self.gameModel = gameModel;
    [self.gameboardView fillWithModel:gameModel];
}

- (void)createTutorialGame {
    self.initialTapPerformed = YES;
    
    NSUInteger level = [[NSUserDefaults standardUserDefaults] integerForKey:@"level"];
    NSArray *map = [self.gameboardView.mineGridView exportMap];
    JMSGameModel *gameModel = [[JMSGameModel alloc] initWithLevel:level map:map];
    [gameModel registerObserver:self];
    [gameModel fillTutorialMapWithLevel:gameModel.level];
    self.gameModel = gameModel;
    [self.gameboardView fillWithModel:gameModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if ([self shouldDisplayTutorial]) {
        [self createTutorialGame];
        _tutorialManager = [[JMSTutorialManager alloc] initWithGameboardController:self
                                                                              size:self.gameboardView.resultsView.bounds.size];
    }
    else {
        if (self.mainViewController.gameModel) {
            [self importFromGameSession];
        }
        else {
            [self createNewGame];
        }
    }
    self.shouldOpenCellInZeroDirection = [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldOpenSafeCells"];
    
    [self configureUI];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view bringSubviewToFront:self.gameboardView.ivSnapshot];
    [self.gameboardView.ivSnapshot setImage:self.mainViewController.mineGridSnapshot];
    [self.gameboardView.ivSnapshot setHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.gameboardView.mineGridView refreshCells];
    [self.gameboardView.ivSnapshot setHidden:YES];

    [self addGestureRecognizers];
    
    if ([self shouldDisplayTutorial] && self.tutorialManager) {
        [self.tutorialManager moveToNextStep];
    }
    
}

- (void)removeGestureRecognizers {
    for (UIGestureRecognizer *gestureRecognizer in self.gameboardView.mineGridView.gestureRecognizers) {
        [self.gameboardView.mineGridView removeGestureRecognizer:gestureRecognizer];
    }
}

- (void)configureUI {
    BOOL tutorialFinished = self.tutorialManager ? self.tutorialManager.isFinished : YES;
    [self.gameboardView updateMenuWithFinishedTutorial:tutorialFinished gameFinished:self.gameboardView.mineGridView.gameFinished];
    UIColor *patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper"]];
    [self.gameboardView.resultsView setBackgroundColor:patternColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeGestureRecognizers];
}

#pragma mark - Gameboard control methods

- (void)finalizeGame {
    [self.gameboardView.mineGridView finalizeGame];
    BOOL tutorialFinished = self.tutorialManager ? self.tutorialManager.isFinished : YES;
    [self.gameboardView updateMenuWithFinishedTutorial:tutorialFinished gameFinished:self.gameboardView.mineGridView.gameFinished];
}

#pragma mark - handle taps

- (void)singleTap: (UIGestureRecognizer *)gestureRecognizer {
    if (self.gameboardView.mineGridView.gameFinished) return; //take from model like (if self.gameboardModel.gameFinished)
    
    CGPoint coord = [gestureRecognizer locationInView:self.gameboardView.mineGridView];
    
    JMSPosition position = [self.gameboardView.mineGridView cellPositionWithCoordinateInside:coord];
    
    if (position.row == NSNotFound || position.column == NSNotFound ||
        ([self shouldDisplayTutorial] && !self.tutorialManager.isFinished && ![self.tutorialManager isAllowedWithAction:JMSAllowedActionsClick
                                                                                                               position:position])) return;
    
    if (!self.initialTapPerformed) {
        [self.gameModel fillMapWithLevel:self.gameModel.level exceptPosition:position];
        self.initialTapPerformed = YES;
    }
    
    if ([self.gameModel isMinePresentAtPosition:position]) {
        [self.gameModel openCellWithPosition:position];
        return;
    }
    else {
        NSUInteger unmarkedCellsCount;
        NSUInteger openedCellsCount;
        BOOL shouldOpenSafeCells = (![self shouldDisplayTutorial] && self.shouldOpenCellInZeroDirection) ||
                                    ([self shouldDisplayTutorial] && self.tutorialManager.currentStep >= JMSTutorialStepLastCellClick);
        BOOL opened = [self.gameModel openInZeroDirectionsFromPosition:position
                                                         unmarkedCount:&unmarkedCellsCount
                                                           openedCount:&openedCellsCount
                                                   shouldOpenSafeCells:shouldOpenSafeCells];
        if (!opened) {
            return;
        }

        if ([self shouldDisplayTutorial] && !self.tutorialManager.isFinished) {
            [self.tutorialManager completeTaskWithPosition:position];
        }
    }
}

- (void)longTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.gameboardView.mineGridView.gameFinished || gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchLocation = [gestureRecognizer locationInView:self.gameboardView.mineGridView];
    JMSPosition position = [self.gameboardView.mineGridView cellPositionWithCoordinateInside:touchLocation];
        
    if (position.row == NSNotFound || position.column == NSNotFound ||
        ([self shouldDisplayTutorial] && !self.tutorialManager.isFinished &&
        ![self.tutorialManager isAllowedWithAction:JMSAllowedActionsMark position:position])) {
        return;
    }
        
    if ([self shouldDisplayTutorial]) {
        if ([self.tutorialManager taskCompletedWithPosition:position]) {
            return;
        }
        else {
            [self.tutorialManager completeTaskWithPosition:position];
        }
    }
        
    [self.gameModel toggleMarkWithPosition:position];
}

- (void)showMessageBox {
    NSString *localizedTitle = NSLocalizedString(@"Play again Btn", @"Play again - button title");
    JMSMessageBoxView *alertView = [[JMSMessageBoxView alloc] initWithButtonTitle:localizedTitle
                                                                    actionHandler:^{
                                                                        [self resetGame];
                                                                    }];
    [alertView setContainerView:[JMSMessageBoxView messageBoxContentView]];
    [alertView setUseMotionEffects:true];
    [alertView show];
}

#pragma mark - Upper Menu Actions

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    return YES;
}

- (IBAction)backToMainMenu {
    if (self.initialTapPerformed && !self.gameboardView.mineGridView.gameFinished) {
        [self.gameModel unregisterObserver:self];

        self.mainViewController.gameModel = self.gameModel;
        self.mainViewController.mineGridSnapshot = [self.gameboardView mineGridViewSnapshot];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)resetGameClicked {
    if (!self.initialTapPerformed) {
        return;
    }
    if (self.gameboardView.mineGridView.gameFinished) {
        [self resetGame];
        return;
    }

    UIAlertController *resetGameController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    NSString *confirmResetString = NSLocalizedString(@"Confirm reset", @"Confirm reset - popover button title");
    UIAlertAction *alertActionYes = [UIAlertAction actionWithTitle:confirmResetString style:UIAlertActionStyleDestructive
                                                               handler:^(UIAlertAction *action) {
                                                                   [self resetGame];
                                                               }];
    [resetGameController addAction:alertActionYes];
    [resetGameController setModalPresentationStyle:UIModalPresentationPopover];
    
    UIPopoverPresentationController *popPresenter = [resetGameController popoverPresentationController];
    popPresenter.sourceView = self.gameboardView.btnResetGame;
    popPresenter.sourceRect = self.gameboardView.btnResetGame.bounds;
    popPresenter.delegate = self;
    [self presentViewController:resetGameController animated:YES completion:nil];
}

- (void)resetGame {
    [self.gameboardView.mineGridView resetGame];
    [self.gameModel unregisterObserver:self];
    self.gameModel = nil;
    [self.mainViewController setGameModel:self.gameModel];
    [self.mainViewController setMineGridSnapshot:nil];
    [self createNewGame];
    [self.gameboardView updateMenuWithFinishedTutorial:YES gameFinished:NO];
}
#pragma mark - Submit results

- (void)postScore {
    [self postScoreLocally];
    if ([[GKLocalPlayer localPlayer] isAuthenticated]) {
        [self postScoreToGameCenter];
    }
}

- (void)postScoreLocally {
    [[[JMSLeaderboardManager alloc] init] postGameScore:lroundf(self.gameModel.score)
                                                  level:self.gameModel.level
                                               progress:self.gameModel.progress];
}

- (void)postScoreToGameCenter {
    // Report the high score to Game Center
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:@"JMSMainLeaderboard"
                                                                     player:[GKLocalPlayer localPlayer]];
    scoreReporter.value = lroundf(self.gameModel.score);

    [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Failed to report score. Reason is: %@", error.localizedDescription);
        }
        else {
            NSLog(@"Reported score successfully");
        }
    }];
}


#pragma mark - Observer methods

- (void)cellsChanged:(NSArray *)alteredCellsCollection {
    for (JMSAlteredCellInfo *alteredCellModel in alteredCellsCollection) {
        [self.gameboardView.mineGridView updateCellWithAlteredCellModel:alteredCellModel];
    }
    [self.gameboardView fillWithModel:self.gameModel];
}

- (void)flagAdded {
    [[JMSSoundHelper instance] playSoundWithAction:JMSSoundActionPutFlag];
}

- (void)flagRemoved {
    [[JMSSoundHelper instance] playSoundWithAction:JMSSoundActionPutFlag];
}

- (void)ranIntoMine {
    [[JMSSoundHelper instance] playSoundWithAction:JMSSoundActionGameFailed];
    [self postScore];
    [self finalizeGame];
    [self.mainViewController setGameModel:nil];
    [self.mainViewController setMineGridSnapshot:nil];
}

- (void)cellSuccessfullyOpened {
    [[JMSSoundHelper instance] playSoundWithAction:JMSSoundActionCellTap];
}

- (void)levelCompleted {
    [[JMSSoundHelper instance] playSoundWithAction:JMSSoundActionLevelCompleted];
    [self postScore];
    [self finalizeGame];
    [self showMessageBox];
}

@end
