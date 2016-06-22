//
//  OptionsViewController.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 10/17/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMSGradientView.h"
#import "JMSGradientButton.h"
#import "JMSGradientSpeedmeterView.h"

@interface JMSOptionsViewController : UIViewController

- (IBAction)save;
- (IBAction)sliderValueChanged:(UISlider *)sender;

@end
