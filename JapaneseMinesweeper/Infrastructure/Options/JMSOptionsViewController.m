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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.level = [userDefaults integerForKey:@"level"];
    self.optionsView.swSoundEnabled.on = [userDefaults boolForKey:@"soundEnabled"];
    self.optionsView.swOpenSafeCells.on = [userDefaults boolForKey:@"shouldOpenSafeCells"];
    CGFloat holdDuration = [userDefaults floatForKey:@"holdDuration"];
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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:self.level forKey:@"level"];
    [userDefaults setBool:self.optionsView.swSoundEnabled.on forKey:@"soundEnabled"];
    [userDefaults setFloat:self.optionsView.slHoldDuration.value forKey:@"holdDuration"];
    [userDefaults setBool:self.optionsView.swOpenSafeCells.on forKey:@"shouldOpenSafeCells"];
    [userDefaults synchronize];
    
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
