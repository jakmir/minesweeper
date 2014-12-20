//
//  OptionsViewController.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 10/17/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientView.h"
#import "GradientButton.h"
@interface OptionsViewController : UIViewController

@property (weak, nonatomic) IBOutlet GradientView *gvEasyLevel;
@property (weak, nonatomic) IBOutlet GradientView *gvHardLevel;
@property (weak, nonatomic) IBOutlet GradientView *gvMiddleLevel;
@property (weak, nonatomic) IBOutlet GradientButton *btnSave;
@property (weak, nonatomic) IBOutlet UILabel *lbHoldDuration;
@property (weak, nonatomic) IBOutlet UISlider *slHoldDuration;
@property (weak, nonatomic) IBOutlet UISwitch *swMute;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonListEasy;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonListMiddle;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonListHard;

- (IBAction)save;
- (IBAction)sliderValueChanged:(UISlider *)sender;

@end
