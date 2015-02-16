//
//  OptionsViewController.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 10/17/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "OptionsViewController.h"
#import "UIColor+ColorFromHexString.h"
#import "Enums.h"

@interface OptionsViewController ()
{
    NSInteger level;
}
@end

@implementation OptionsViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeFromUserDefaults];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (UIButton *button in self.buttonListEasy) {
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    for (UIButton *button in self.buttonListMiddle) {
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    for (UIButton *button in self.buttonListHard) {
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    for (UIButton *button in self.buttonListEasy)
    {
        [button removeTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    for (UIButton *button in self.buttonListMiddle)
    {
        [button removeTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    for (UIButton *button in self.buttonListHard)
    {
        [button removeTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.gvEasyLevel drawGradientWithStartColor:[UIColor colorFromInteger:0xfff0fff7]
                                  andFinishColor:[UIColor whiteColor]];
    [self.gvMiddleLevel drawGradientWithStartColor:[UIColor colorFromInteger:0xfffff7f0]
                                    andFinishColor:[UIColor whiteColor]];
    [self.gvHardLevel drawGradientWithStartColor:[UIColor colorFromInteger:0xfffff0f0]
                                  andFinishColor:[UIColor whiteColor]];
    [self.btnSave drawGradientWithStartColor:[UIColor colorFromInteger:0xff00cfff]
                              andFinishColor:[UIColor colorFromInteger:0xff007fff]];
    
    UIButton *button = (UIButton *)[self.view viewWithTag:level];
    if (button)
    {
        [self buttonClick:button];
    }
    
    self.generalSettings.center = CGPointMake(CGRectGetMidX(self.view.frame),
                                              (CGRectGetMaxY(self.difficultyLevel.frame) + CGRectGetMinY(self.btnSave.frame)) / 2);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) buttonClick: (UIButton *)button
{
    UIColor *selectedTextColor;
    JMSGameDifficulty buttonType = [self buttonType:button];
    switch (buttonType) {
        case JMSGameDifficultyEasy:
            selectedTextColor = [UIColor colorFromInteger:0xff66cc99];
            break;
        case JMSGameDifficultyMedium:
            selectedTextColor = [UIColor colorFromInteger:0xffffcc00];
            break;
        case JMSGameDifficultyHard:
            selectedTextColor = [UIColor colorFromInteger:0xffff3300];
            break;
        default:
            return;
    }
    
    UIButton *currentSelectedButton = (UIButton *)[self.view viewWithTag:level];
    if ([currentSelectedButton isKindOfClass:[UIButton class]])
    {
        [self deselectButton:currentSelectedButton];
    }
    currentSelectedButton = button;
    level = button.tag;
    [self selectButton:button withColor:selectedTextColor];
    
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

- (JMSGameDifficulty)buttonType:(UIButton *)button
{
    if ([self.buttonListEasy containsObject:button])
        return JMSGameDifficultyEasy;
    if ([self.buttonListMiddle containsObject:button])
        return JMSGameDifficultyMedium;
    if ([self.buttonListHard containsObject:button])
        return JMSGameDifficultyHard;
    return JMSGameDifficultyUndefined;
}

@end
