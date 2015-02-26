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

@interface JMSOptionsViewController ()
{
    NSInteger level;
}
@end

@implementation JMSOptionsViewController

- (void)initializeFromUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    level = [userDefaults integerForKey:@"level"];
    self.swSoundEnabled.on = [userDefaults boolForKey:@"soundEnabled"];
    self.swGameCenterSubmit.on = [userDefaults boolForKey:@"shouldSubmitToGameCenter"];
    CGFloat holdDuration = [userDefaults floatForKey:@"holdDuration"];
    self.slHoldDuration.value = holdDuration;
    [self sliderValueChanged:self.slHoldDuration];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeFromUserDefaults];
    [self.gradientSpeedmeter setMinimumValue:16];
    [self.gradientSpeedmeter setMaximumValue:39];
    [self.gradientSpeedmeter setPower:level];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valueChanged:)
                                                 name:@"SpeedmeterValueChanged" object:nil];

}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.btnSave setNeedsDisplay];
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    
    [self.btnSave drawGradientWithStartColor:[UIColor colorFromInteger:0xff00cfff]
                              andFinishColor:[UIColor colorFromInteger:0xff007fff]];
    [self.btnSave.layer setCornerRadius:16];
    [self.btnSave.layer setMasksToBounds:YES];
    self.generalSettings.center = CGPointMake(CGRectGetMidX(self.view.frame),
                                              (CGRectGetMaxY(self.difficultyLevel.frame) + CGRectGetMinY(self.btnSave.frame)) / 2);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:level forKey:@"level"];
    [userDefaults setBool:self.swSoundEnabled.on forKey:@"soundEnabled"];
    [userDefaults setFloat:self.slHoldDuration.value forKey:@"holdDuration"];
    [userDefaults setBool:self.swGameCenterSubmit.on forKey:@"shouldSubmitToGameCenter"];
    [userDefaults synchronize];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)valueChanged:(NSNotification *)notification
{
    level = self.gradientSpeedmeter.power;
}

- (IBAction)sliderValueChanged:(UISlider *)sender
{
    self.lbHoldDuration.text = [NSString stringWithFormat:@"%0.2f", sender.value];
}

- (void)selectButton: (UIButton *)button withColor: (UIColor *)color
{
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:48]];
    [button setTitleColor:color forState:UIControlStateNormal];
}

- (void)deselectButton: (UIButton *)button
{
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:36]];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

@end
