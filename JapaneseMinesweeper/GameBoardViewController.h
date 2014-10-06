//
//  GameBoardViewController.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MineGridView.h"
#import "GradientView.h"
#import "GradientButton.h"

@interface GameBoardViewController : UIViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet MineGridView *mineGridView;
@property (nonatomic) CGFloat coverageRate;
@property (weak, nonatomic) IBOutlet UILabel *lbScore;
@property (weak, nonatomic) IBOutlet UILabel *lbCellsLeft;
@property (weak, nonatomic) IBOutlet UILabel *lbCellsMarked;

@property (weak, nonatomic) IBOutlet GradientView *scoreView;
@property (weak, nonatomic) IBOutlet GradientView *cellsCountView;
@property (weak, nonatomic) IBOutlet GradientView *markedMinesCountView;

@property (weak, nonatomic) IBOutlet GradientButton *btnMainMenu;
@property (weak, nonatomic) IBOutlet GradientButton *btnLeaderboards;

@end
