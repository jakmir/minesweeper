//
//  JMSKeyValueSettingsHelper.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/24/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * const kUserDefaultsInitializedKey;
extern NSString * const kShouldLaunchTutorialKey;
extern NSString * const kShouldOpenSafeCellsKey;
extern NSString * const kHoldDurationKey;
extern NSString * const kLevelKey;
extern NSString * const kSoundEnabledKey;

@interface JMSSettings : NSObject

+ (instancetype)shared;
- (UIColor *)gradientStartColor;
- (UIColor *)gradientFinishColor;
- (UIColor *)completedPercentageLabelColor;
- (UIColor *)progressPercentageLabelColor;
- (UIColor *)antDashedBorderColor;
- (CGFloat)menuButtonCornerRadius;
- (CGFloat)buttonCornerRadius;

- (BOOL)shouldLaunchTutorial;
- (void)setShouldLaunchTutorial:(BOOL)shouldLaunchTutorial;

- (BOOL)shouldOpenSafeCells;
- (void)setShouldOpenSafeCells:(BOOL)shouldOpenSafeCells;

- (CGFloat)minimumPressDuration;
- (void)setMinimumPressDuration:(CGFloat)minimumPressDuration;

- (NSUInteger)level;
- (void)setLevel:(NSUInteger)level;

- (BOOL)soundEnabled;
- (void)setSoundEnabled:(BOOL)soundEnabled;

@end
