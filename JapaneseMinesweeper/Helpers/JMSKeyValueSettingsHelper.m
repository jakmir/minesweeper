//
//  JMSKeyValueSettingsHelper.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/24/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSKeyValueSettingsHelper.h"
#import "UIColor+ColorFromHexString.h"

@implementation JMSKeyValueSettingsHelper {
    NSDictionary *_dictionary;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        _dictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    }
    return self;
}

+ (instancetype)instance
{
    static JMSKeyValueSettingsHelper *anInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        anInstance = [[JMSKeyValueSettingsHelper alloc] init];
    });
    return anInstance;
}

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

@end
