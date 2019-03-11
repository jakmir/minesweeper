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

- (CAGradientLayer *)gradientLayer {
    if (_gradientLayer == nil) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.bounds;
        _gradientLayer.startPoint = CGPointMake(0.5, 0.0);
        _gradientLayer.endPoint = CGPointMake(0.5, 1.0);
        _gradientLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        
        [self.layer insertSublayer:_gradientLayer
                             below:[self.layer.sublayers firstObject]];
    }
    return _gradientLayer;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 10.0f;
    self.layer.masksToBounds = YES;
}

- (void)drawGradientWithStartColor:(UIColor *)startColor finishColor:(UIColor *)finishColor {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    self.gradientLayer.colors = @[(id)startColor.CGColor, (id)finishColor.CGColor];
    [CATransaction commit];
}

@end
