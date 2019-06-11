//
//  OptionsViewController.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 10/17/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "JMSOptionsViewController.h"
#import "UIColor+ColorFromHexString.h"
#import "Enums.h"
#import "JMSSoundHelper.h"
#import "JMSOptionsView.h"

@interface JMSOptionsViewController () <JMSGradientSpeedmeterViewDelegate>

@property (nonatomic) NSInteger level;
@property (nonatomic, readonly) JMSOptionsView *optionsView;

@end

@implementation JMSOptionsViewController

- (void)initializeFromUserDefaults {
    self.level = [[JMSSettings shared] level];
    self.optionsView.swSoundEnabled.on = [[JMSSettings shared] soundEnabled];
    self.optionsView.swOpenSafeCells.on = [[JMSSettings shared] shouldOpenSafeCells];
    CGFloat holdDuration = [[JMSSettings shared] minimumPressDuration];
    self.optionsView.slHoldDuration.value = holdDuration;
    [self sliderValueChanged:self.optionsView.slHoldDuration];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (JMSOptionsView *)optionsView {
    if ([self.view isKindOfClass:[JMSOptionsView class]]) {
        return (JMSOptionsView *)self.view;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeFromUserDefaults];
    [self.optionsView.gradientSpeedmeter setDelegate:self];
    [self.optionsView fillGradientSpeedmeterWithLevel:self.level];
}

- (IBAction)save {
    JMSSettings *settings = [JMSSettings shared];
    [settings setLevel:self.level];
    [settings setSoundEnabled:self.optionsView.swSoundEnabled.on];
    [settings setMinimumPressDuration:self.optionsView.slHoldDuration.value];
    [settings setShouldOpenSafeCells:self.optionsView.swOpenSafeCells.on];

    [[JMSSoundHelper shared] muteSound:!self.optionsView.swSoundEnabled.on];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    [self.optionsView updateHoldDurationWithValue:sender.value];
}

- (void)didSpeedmeterValueChange:(JMSGradientSpeedmeterView *)sender value:(NSUInteger)value {
    self.level = value;
}

@end
