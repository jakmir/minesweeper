//
//  JMSKeyValueSettingsHelper.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/24/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSSettings.h"
#import "UIColor+ColorFromHexString.h"

NSString * const kShouldLaunchTutorialKey = @"shouldLaunchTutorial";
NSString * const kShouldOpenSafeCellsKey = @"shouldOpenSafeCells";
NSString * const kHoldDurationKey = @"holdDuration";
NSString * const kLevelKey = @"level";
NSString * const kSoundEnabledKey = @"soundEnabled";
NSString * const kUserDefaultsInitializedKey = @"userDefaultsInitialized";

@interface JMSSettings()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation JMSSettings

- (instancetype)init {
    if (self = [super init]) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        _dictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    }
    return self;
}

+ (instancetype)shared {
    static JMSSettings *anInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        anInstance = [[JMSSettings alloc] init];
    });
    return anInstance;
}

#pragma mark - Internal settings

- (UIColor *)gradientStartColor {
    return [UIColor colorFromInteger:[_dictionary[@"gradientStartColor"] intValue]];
}

- (UIColor *)gradientFinishColor {
    return [UIColor colorFromInteger:[_dictionary[@"gradientFinishColor"] intValue]];
}

- (UIColor *)progressPercentageLabelColor {
    return [UIColor colorFromInteger:[_dictionary[@"progressPercentageLabelColor"] intValue]];
}

- (UIColor *)completedPercentageLabelColor {
    return [UIColor colorFromInteger:[_dictionary[@"completedPercentageLabelColor"] intValue]];
}

- (UIColor *)antDashedBorderColor {
    return [UIColor colorFromInteger:[_dictionary[@"antDashedBorderColor"] intValue]];
}

- (CGFloat)menuButtonCornerRadius {
    return [_dictionary[@"menuButtonCornerRadius"] doubleValue];
}

- (CGFloat)buttonCornerRadius {
    return [_dictionary[@"buttonCornerRadius"] doubleValue];
}

#pragma mark - Preferences

- (BOOL)shouldLaunchTutorial {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldLaunchTutorialKey];
}

- (void)setShouldLaunchTutorial:(BOOL)shouldLaunchTutorial {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:shouldLaunchTutorial forKey:kShouldLaunchTutorialKey];
    [userDefaults synchronize];
}

- (BOOL)shouldOpenSafeCells {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldOpenSafeCellsKey];
}

- (void)setShouldOpenSafeCells:(BOOL)shouldOpenSafeCells {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:shouldOpenSafeCells forKey:kShouldOpenSafeCellsKey];
    [userDefaults synchronize];
}

- (CGFloat)minimumPressDuration {
    return [[NSUserDefaults standardUserDefaults] floatForKey:kHoldDurationKey];
}

- (void)setMinimumPressDuration:(CGFloat)minimumPressDuration {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:minimumPressDuration forKey:kHoldDurationKey];
    [userDefaults synchronize];
}

- (NSUInteger)level {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kLevelKey];
}

- (void)setLevel:(NSUInteger)level {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:level forKey:kLevelKey];
    [userDefaults synchronize];
}

- (BOOL)soundEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSoundEnabledKey];
}

- (void)setSoundEnabled:(BOOL)soundEnabled {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:soundEnabled forKey:kSoundEnabledKey];
    [userDefaults synchronize];
}
@end
