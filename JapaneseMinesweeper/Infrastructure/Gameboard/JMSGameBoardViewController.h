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
#import "AlteredCellObserver.h"

@class JMSMainViewController;
@class JMSGameboardView;

@interface JMSGameBoardViewController : UIViewController<UIPopoverPresentationControllerDelegate, AlteredCellObserver>

@property (weak, nonatomic) JMSMainViewController *mainViewController;
@property (nonatomic, strong) JMSGameModel *gameModel;
@property (strong, nonatomic) id gameboardModel;

- (void)cellsChanged:(NSArray *)alteredCellsCollection;

- (IBAction)backToMainMenu;
- (IBAction)resetGameClicked;

- (JMSGameboardView *)gameboardView;

@end
