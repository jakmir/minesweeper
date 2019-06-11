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
    return [[JMSSettings shared] progressPercentageLabelColor];
}

+ (UIColor *)completedPercentageLabelColor {
    return [[JMSSettings shared] completedPercentageLabelColor];
}

+ (UIColor *)gradientStartColor {
    return [[JMSSettings shared] gradientStartColor];
}

+ (UIColor *)gradientFinishColor {
    return [[JMSSettings shared] gradientFinishColor];
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
    return [[JMSSettings shared] antDashedBorderColor];
}

+ (UIColor *)needleColor {
    return [UIColor clearColor];
}
@end
