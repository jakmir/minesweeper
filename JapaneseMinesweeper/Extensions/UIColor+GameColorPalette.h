//
//  UIColor+GameColorPalette.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/27/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (GameColorPalette)

+ (UIColor *)gradientStartColor;
+ (UIColor *)gradientFinishColor;
+ (UIColor *)completedPercentageLabelColor;
+ (UIColor *)progressPercentageLabelColor;
+ (UIColor *)brightOrangeColor;
+ (UIColor *)brightPurpleColor;
+ (UIColor *)juicyOrangeColor;
+ (UIColor *)needleColor;

@end
