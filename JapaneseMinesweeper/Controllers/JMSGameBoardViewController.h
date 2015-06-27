//
//  GameBoardViewController.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMSMineGridView.h"
#import "JMSGradientView.h"
#import "JMSGradientButton.h"
#import "JMSMessageBoxView.h"

@class JMSMainViewController;

@interface JMSGameBoardViewController : UIViewController<UIActionSheetDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *ivSnapshot;
@property (weak, nonatomic) IBOutlet JMSMineGridView *mineGridView;

@property (weak, nonatomic) IBOutlet UILabel *lbScore;
@property (weak, nonatomic) IBOutlet UILabel *lbProgress;
@property (weak, nonatomic) IBOutlet UILabel *lbCellsMarked;

@property (weak, nonatomic) IBOutlet JMSGradientView *scoreView;
@property (weak, nonatomic) IBOutlet JMSGradientView *cellsCountView;
@property (weak, nonatomic) IBOutlet JMSGradientView *markedMinesCountView;
@property (weak, nonatomic) IBOutlet UIView *resultsView;
@property (weak, nonatomic) IBOutlet UIView *buttonsPanelView;

@property (weak, nonatomic) IBOutlet UIButton *btnMainMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnResetGame;

@property (weak, nonatomic) JMSMainViewController *mainViewController;

- (IBAction)backToMainMenu;
- (IBAction)resetGameClicked;

- (void)finishTutorial;

@end
