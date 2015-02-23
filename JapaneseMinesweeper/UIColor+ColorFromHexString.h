//
//  UIColor+ColorFromHexString.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 10/6/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorFromHexString)

+ (UIColor *)colorFromHexString: (NSString *)hexString;
+ (UIColor *)colorFromInteger: (UInt32)integer;

@end
