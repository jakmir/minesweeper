//
//  GradientButton.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 10/6/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "JMSGradientButton.h"

@interface JMSGradientButton()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation JMSGradientButton

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!self.gradientLayer) {
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = rect;
        self.gradientLayer.startPoint = CGPointMake(0.5, 0.0);
        self.gradientLayer.endPoint = CGPointMake(0.5, 1.0);
        self.gradientLayer.position = CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetHeight(rect) / 2);
        
        [self.layer insertSublayer:self.gradientLayer
                             below:[self.layer.sublayers firstObject]];
    }
    
    self.layer.cornerRadius = 10.0f;
    self.layer.masksToBounds = YES;
}

- (void)drawGradientWithStartColor:(UIColor *)startColor finishColor:(UIColor *)finishColor {
    if (!self.gradientLayer) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.gradientLayer.colors = @[(id)startColor.CGColor, (id)finishColor.CGColor];
    [CATransaction commit];
}

@end
