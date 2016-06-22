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

@class JMSGameModel;

@interface JMSMainViewController : UIViewController

@property (strong, nonatomic) UIImage *mineGridSnapshot;
@property (strong, nonatomic) JMSGameModel *gameModel;

- (IBAction)showAboutScreen:(UIButton *)sender;

@end

