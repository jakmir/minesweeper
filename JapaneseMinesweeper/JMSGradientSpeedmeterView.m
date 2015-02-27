//
//  JMSGradientSpeedmeterView.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/16/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSGradientSpeedmeterView.h"
#import "UIColor+ColorFromHexString.h"

@implementation JMSGradientSpeedmeterView
{
    CAShapeLayer *shapeLayer;
    UIPanGestureRecognizer *panGestureRecognizer;
    UITapGestureRecognizer *tapGestureRecognizer;
    UILabel *lbPower;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _minimumValue = 0;
        _maximumValue = UINT32_MAX;
        _power = 0;
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOrTap:)];
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panOrTap:)];
        [self addGestureRecognizer:panGestureRecognizer];
        [self addGestureRecognizer:tapGestureRecognizer];
        
        CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height * 0.95);
        lbPower = [[UILabel alloc] initWithFrame:CGRectMake(centerPoint.x - 100, centerPoint.y / 0.95 - 128, 200, 128)];
        lbPower.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lbPower];
    }
    return self;
}

- (void)dealloc
{
    [self removeGestureRecognizer:panGestureRecognizer];
    [self removeGestureRecognizer:tapGestureRecognizer];
}

- (void)setMinimumValue:(NSUInteger)minimumValue
{
    _minimumValue = minimumValue;
    if (_minimumValue >= _maximumValue)
    {
        _minimumValue = _maximumValue - 1;
    }
}

- (void)setMaximumValue:(NSUInteger)maximumValue
{
    _maximumValue = maximumValue;
    if (_maximumValue <= _minimumValue)
    {
        _maximumValue = _minimumValue + 1;
    }
}
- (void)setPower:(NSUInteger)power
{
    _power = MAX(_minimumValue, MIN(power, _maximumValue));
    [self setNeedsDisplay];

    NSAttributedString *str = [[NSAttributedString alloc] initWithString:[@(_power) stringValue]
                                                              attributes:@{
                                                                            NSForegroundColorAttributeName:
                                                                                [UIColor colorFromInteger:0xffcfcfcf],
                                                                            NSFontAttributeName:
                                                                                [UIFont fontWithName:@"HelveticaNeue-Bold" size:128],
                                                                          }];
    [lbPower setAttributedText:str];
   
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    UIRectFill(self.bounds);
    CGFloat width = self.bounds.size.width;
    NSUInteger discreteStepsCount = 256;
    CGFloat innerRadius = width/4, outerRadius = width/2;

    float smallBase= M_PI * innerRadius / discreteStepsCount;
    float largeBase= M_PI * outerRadius / discreteStepsCount;
    
    UIBezierPath * cell = [UIBezierPath bezierPath];
    
    [cell moveToPoint:CGPointMake(-smallBase/2, innerRadius )];
    
    [cell addLineToPoint:CGPointMake(smallBase/2, innerRadius )];
    
    [cell addLineToPoint:CGPointMake(largeBase / 2, outerRadius )];
    [cell addLineToPoint:CGPointMake(-largeBase /2, outerRadius )];
    [cell closePath];
    
    NSUInteger extraSteps = 20;
    CGFloat incrementalAngle = M_PI / discreteStepsCount;

    CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height * 0.95);
    CGContextTranslateCTM(context, centerPoint.x, centerPoint.y);
    
    CGContextScaleCTM(context, 0.9, 0.9);
    CGContextRotateCTM(context, M_PI / 2 - M_PI / extraSteps);
    CGContextRotateCTM(context,-incrementalAngle/2);
    
    for (NSUInteger i=0; i<discreteStepsCount + extraSteps * 3; i++)
    {
        CGFloat hue = 0.25 * (1 - (CGFloat)i/discreteStepsCount);
        [[UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1] set];
        [cell fill];
        [cell stroke];
        CGContextRotateCTM(context, incrementalAngle);
    }
    
    CGFloat progressAngle = M_PI * ((CGFloat)(_power - _minimumValue) / (_maximumValue - _minimumValue));
    CGPoint p1 = CGPointMake(centerPoint.x - cos(progressAngle - M_PI / 60) * (innerRadius * 0.89),
                             centerPoint.y - sin(progressAngle - M_PI / 60) * (innerRadius * 0.89));
    CGPoint p2 = CGPointMake(centerPoint.x - cos(progressAngle + M_PI / 60) * (innerRadius * 0.89),
                             centerPoint.y - sin(progressAngle + M_PI / 60) * (innerRadius * 0.89));
    CGPoint p3 = CGPointMake(centerPoint.x - cos(progressAngle - M_PI / 52) * (outerRadius * 0.8),
                             centerPoint.y - sin(progressAngle - M_PI / 52) * (outerRadius * 0.8));
    CGPoint p4 = CGPointMake(centerPoint.x - cos(progressAngle + M_PI / 52) * (outerRadius * 0.8),
                             centerPoint.y - sin(progressAngle + M_PI / 52) * (outerRadius * 0.8));
    CGPoint p5 = CGPointMake(centerPoint.x - cos(progressAngle) * outerRadius * 0.875,
                             centerPoint.y - sin(progressAngle) * outerRadius * 0.875);
    if (shapeLayer != nil)
    {
        [shapeLayer removeFromSuperlayer];
    }
    
    shapeLayer = [CAShapeLayer layer];
    CGMutablePathRef path = CGPathCreateMutable();
    

    CGPathMoveToPoint(path, nil, p1.x, p1.y);
    CGPathAddLineToPoint(path, nil, p2.x, p2.y);
    CGPathAddLineToPoint(path, nil, p4.x, p4.y);
    CGPathAddLineToPoint(path, nil, p5.x, p5.y);
    CGPathAddLineToPoint(path, nil, p3.x, p3.y);
    CGPathCloseSubpath(path);
    
    shapeLayer.path = path;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.fillColor = [UIColor colorFromInteger:0x3fffffff].CGColor;
    shapeLayer.lineWidth = 2;
    CGPathRelease(path);
    [self.layer addSublayer:shapeLayer];
    

}

- (void)panOrTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchLocation = [gestureRecognizer locationInView:self];
    CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height * 0.95);
    CGFloat width = self.bounds.size.width;
    CGFloat innerRadius = width/(4/0.9), outerRadius = width/(2/0.9);
    CGFloat distance = hypot(centerPoint.x - touchLocation.x, MAX(centerPoint.y - touchLocation.y, 0));
    BOOL inside = distance >= innerRadius && distance <= outerRadius && touchLocation.y < centerPoint.y / 0.95;
    if (!inside) return;
    
    CGFloat mirroredAngle = acos((touchLocation.x - centerPoint.x) / distance);

    NSUInteger power = lround((1 - mirroredAngle / M_PI) * (_maximumValue - _minimumValue) + _minimumValue);

    if (_power != power)
    {
        [self setPower:power];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SpeedmeterValueChanged" object:nil];
    }
    
    
}


@end
