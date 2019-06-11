//
//  JMSOptionsView.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/5/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import "JMSOptionsView.h"
#import "JMSGradientSpeedmeterView.h"
#import "JMSGradientButton.h"

@implementation JMSOptionsView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.btnSave drawGradientWithStartColor:[[JMSSettings shared] gradientStartColor]
                                 finishColor:[[JMSSettings shared] gradientFinishColor]];
    [self.btnSave.layer setCornerRadius:[[JMSSettings shared] menuButtonCornerRadius]];
    [self.btnSave.layer setMasksToBounds:YES];
}

- (void)fillGradientSpeedmeterWithLevel:(NSUInteger)level {
    [self.gradientSpeedmeter setMinimumValue:16];
    [self.gradientSpeedmeter setMaximumValue:39];
    [self.gradientSpeedmeter setPower:level];
}

- (void)updateHoldDurationWithValue:(float)holdDuration {
    NSString *formatString = NSLocalizedString(@"SecondSliderFormatString", @"String appears next to the slider");
    self.lbHoldDuration.text = [NSString stringWithFormat:formatString, holdDuration];
}
@end
