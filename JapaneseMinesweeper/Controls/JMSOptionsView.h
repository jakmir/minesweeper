//
//  JMSOptionsView.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/5/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JMSGradientSpeedmeterView;
@class JMSGradientButton;

@interface JMSOptionsView : UIView

@property (weak, nonatomic) IBOutlet UIView *difficultyLevel;
@property (weak, nonatomic) IBOutlet UIView *generalSettings;
@property (weak, nonatomic) IBOutlet JMSGradientSpeedmeterView *gradientSpeedmeter;

@property (weak, nonatomic) IBOutlet JMSGradientButton *btnSave;
@property (weak, nonatomic) IBOutlet UILabel *lbHoldDuration;
@property (weak, nonatomic) IBOutlet UISlider *slHoldDuration;
@property (weak, nonatomic) IBOutlet UISwitch *swSoundEnabled;
@property (weak, nonatomic) IBOutlet UISwitch *swOpenSafeCells;

- (void)fillGradientSpeedmeterWithLevel:(NSUInteger)level;
- (void)updateHoldDurationWithValue:(float)holdDuration;

@end
