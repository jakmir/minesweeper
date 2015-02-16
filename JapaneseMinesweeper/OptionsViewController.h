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
@interface OptionsViewController : UIViewController

@property (weak, nonatomic) IBOutlet JMSGradientView *gvEasyLevel;
@property (weak, nonatomic) IBOutlet JMSGradientView *gvHardLevel;
@property (weak, nonatomic) IBOutlet JMSGradientView *gvMiddleLevel;
@property (weak, nonatomic) IBOutlet UIView *difficultyLevel;
@property (weak, nonatomic) IBOutlet UIView *generalSettings;

@property (weak, nonatomic) IBOutlet JMSGradientButton *btnSave;
@property (weak, nonatomic) IBOutlet UILabel *lbHoldDuration;
@property (weak, nonatomic) IBOutlet UISlider *slHoldDuration;
@property (weak, nonatomic) IBOutlet UISwitch *swSoundEnabled;
@property (weak, nonatomic) IBOutlet UISwitch *swGameCenterSubmit;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonListEasy;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonListMiddle;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonListHard;

- (IBAction)save;
- (IBAction)sliderValueChanged:(UISlider *)sender;

@end
