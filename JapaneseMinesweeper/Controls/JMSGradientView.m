//
//  GradientView.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 10/6/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "JMSGradientView.h"

@interface JMSGradientView()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation JMSGradientView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_gradientLayer == nil) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = rect;
        _gradientLayer.startPoint = CGPointMake(0.5, 0.0);
        _gradientLayer.endPoint = CGPointMake(0.5, 1.0);
        _gradientLayer.position = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    }
 
    self.layer.cornerRadius = 10.0f;
    self.layer.masksToBounds = YES;
}

- (void)drawGradientWithStartColor:(UIColor *)startColor andFinishColor:(UIColor *)finishColor {
    if (!self.gradientLayer) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.gradientLayer.colors = @[(id)startColor.CGColor, (id)finishColor.CGColor];
    [CATransaction commit];
}

@end
