//
//  UIColor+GameColorPalette.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/27/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "UIColor+GameColorPalette.h"
#import "UIColor+ColorFromHexString.h"

@implementation UIColor (GameColorPalette)

+ (UIColor *)progressPercentageLabelColor {
    return [[JMSKeyValueSettingsHelper instance] progressPercentageLabelColor];
}

+ (UIColor *)completedPercentageLabelColor {
    return [[JMSKeyValueSettingsHelper instance] completedPercentageLabelColor];
}

+ (UIColor *)gradientStartColor {
    return [[JMSKeyValueSettingsHelper instance] gradientStartColor];
}

+ (UIColor *)gradientFinishColor {
    return [[JMSKeyValueSettingsHelper instance] gradientFinishColor];
}

+ (UIColor *)juicyOrangeColor {
    return [UIColor colorFromInteger:0xffff6600];
}

+ (UIColor *)brightOrangeColor {
    return [UIColor colorFromInteger:0xffff3300];
}

+ (UIColor *)brightPurpleColor {
    return [UIColor colorFromInteger:0xffa818ff];
}

+ (UIColor *)antDashedBorderColor {
    return [[JMSKeyValueSettingsHelper instance] antDashedBorderColor];
}

+ (UIColor *)needleColor {
    return [UIColor clearColor];
}
@end
