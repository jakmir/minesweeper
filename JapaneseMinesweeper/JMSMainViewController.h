//
//  ViewController.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/12/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMSGradientButton.h"
#import "JMSAboutViewController.h"

@class JMSGameSessionInfo;

@interface JMSMainViewController : UIViewController

@property (weak, nonatomic) IBOutlet JMSGradientButton *btnStart;
@property (weak, nonatomic) IBOutlet JMSGradientButton *btnComplexityLevel;
@property (weak, nonatomic) IBOutlet JMSGradientButton *btnLeaderboard;
@property (weak, nonatomic) IBOutlet JMSGradientButton *btnTutorial;
@property (weak, nonatomic) IBOutlet UIView *buttonListContainer;
@property (strong, nonatomic) UIImage *mineGridSnapshot;

@property (nonatomic, strong) JMSGameSessionInfo *gameSessionInfo;

- (IBAction)showAboutScreen:(UIButton *)sender;

@end

