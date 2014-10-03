//
//  GameBoardViewController.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MineGridView.h"
@interface GameBoardViewController : UIViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet MineGridView *mineGridView;
@property (nonatomic) CGFloat coverageRate;
@property (weak, nonatomic) IBOutlet UILabel *lbScore;
@property (weak, nonatomic) IBOutlet UILabel *lbCellsLeft;

@end
