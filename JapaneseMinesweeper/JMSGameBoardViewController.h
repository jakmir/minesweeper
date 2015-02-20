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

@class MainViewController;

@interface JMSGameBoardViewController : UIViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet JMSMineGridView *mineGridView;

@property (weak, nonatomic) IBOutlet UILabel *lbScore;
@property (weak, nonatomic) IBOutlet UILabel *lbProgress;
@property (weak, nonatomic) IBOutlet UILabel *lbCellsMarked;

@property (weak, nonatomic) IBOutlet JMSGradientView *scoreView;
@property (weak, nonatomic) IBOutlet JMSGradientView *cellsCountView;
@property (weak, nonatomic) IBOutlet JMSGradientView *markedMinesCountView;
@property (weak, nonatomic) IBOutlet UIView *resultsView;
@property (weak, nonatomic) IBOutlet UIView *buttonsPanelView;

@property (weak, nonatomic) IBOutlet JMSGradientButton *btnMainMenu;
@property (weak, nonatomic) IBOutlet JMSGradientButton *btnResetGame;

@property (weak, nonatomic) MainViewController *mainViewController;

- (IBAction)backToMainMenu;
- (IBAction)resetGame;

@end
