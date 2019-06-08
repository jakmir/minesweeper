//
//  JMSKeyValueSettingsHelper.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/24/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JMSKeyValueSettingsHelper : NSObject

+ (instancetype)instance;
- (UIColor *)gradientStartColor;
- (UIColor *)gradientFinishColor;
- (UIColor *)completedPercentageLabelColor;
- (UIColor *)progressPercentageLabelColor;
- (UIColor *)antDashedBorderColor;
- (CGFloat)menuButtonCornerRadius;
- (CGFloat)buttonCornerRadius;

@end
