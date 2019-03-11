//
//  UIColor+ColorFromHexString.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 10/6/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "UIColor+ColorFromHexString.h"

@implementation UIColor (ColorFromHexString)

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    uint result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    
    [scanner scanHexInt:&result];

    return [UIColor colorFromInteger:result];
}

+ (UIColor *)colorFromInteger:(UInt32)integer {
    return [UIColor colorWithRed:((integer >> 16) & 0xFF) / 255.0
                           green:((integer >> 8) & 0xFF) / 255.0
                            blue:(integer & 0xFF) / 255.0
                           alpha:((integer >> 24) & 0xFF) / 255.0];
}
@end
