//
//  JMSGameboardView.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 5/18/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMSMineGridView.h"
#import "JMSGradientView.h"
#import "JMSGameModel.h"

@interface JMSGameboardView : UIView

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

- (void)fillWithModel:(JMSGameModel *)model;
- (UIImage *)mineGridViewSnapshot;
- (void)updateMenuWithFinishedTutorial:(BOOL)tutorialFinished gameFinished:(BOOL)gameFinished;

@end
