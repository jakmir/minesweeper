//
//  ViewController.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/12/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMSGradientButton.h"


@class JMSGameSessionInfo;

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet JMSGradientButton *btnStart;
@property (weak, nonatomic) IBOutlet JMSGradientButton *btnComplexityLevel;
@property (weak, nonatomic) IBOutlet JMSGradientButton *btnLeaderboard;
@property (weak, nonatomic) IBOutlet JMSGradientButton *btnTutorial;
@property (weak, nonatomic) IBOutlet UIView *buttonListContainer;

@property (nonatomic, strong) JMSGameSessionInfo *gameSessionInfo;

@end

