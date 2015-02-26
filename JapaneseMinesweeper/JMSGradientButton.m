//
//  GradientButton.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 10/6/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "JMSGradientButton.h"

@implementation JMSGradientButton
{
    CAGradientLayer *layer;
    
}

- (void)drawRect:(CGRect)rect
{
    NSLog(@"%s", __FUNCTION__);
    [super drawRect:rect];
    
    if (!layer)
    {
        layer = [CAGradientLayer layer];
        layer.frame = rect;
        layer.startPoint = CGPointMake(0.5, 0.0);
        layer.endPoint = CGPointMake(0.5, 1.0);
        layer.position = CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetHeight(rect) / 2);
        
        [self.layer insertSublayer:layer below:[self.layer.sublayers firstObject]];
    }
    
    self.layer.cornerRadius = 10.0f;
    self.layer.masksToBounds = YES;
}

- (void) drawGradientWithStartColor:(UIColor *)startColor andFinishColor:(UIColor *)finishColor;
{
    NSLog(@"%s", __FUNCTION__);
    
    if (!layer) return;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    layer.colors = @[(id)startColor.CGColor, (id)finishColor.CGColor];
    [CATransaction commit];
}

@end
