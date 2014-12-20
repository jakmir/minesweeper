//
//  ViewController.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/12/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientButton.h"

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet GradientButton *btnStart;
@property (weak, nonatomic) IBOutlet GradientButton *btnComplexityLevel;
@property (weak, nonatomic) IBOutlet GradientButton *btnLeaderboard;

- (IBAction)startGame;

@end

