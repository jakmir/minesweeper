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
    UIPanGestureRecognizer *gestureRecognizer;
    UILabel *lbPower;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        _minimumValue = 0;
        _maximumValue = 1;
        _power = 0;
        gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:gestureRecognizer];
        
        CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height * 0.95);
        lbPower = [[UILabel alloc] initWithFrame:CGRectMake(centerPoint.x - 100, centerPoint.y - 100, 200, 100)];
        lbPower.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lbPower];
    }
    return self;
}

- (void)dealloc
{
    [self removeGestureRecognizer:gestureRecognizer];
}

- (void)setPower:(NSUInteger)power
{
    _power = MAX(_minimumValue, MIN(power, _maximumValue));
    [self setNeedsDisplay];

    NSAttributedString *s = [[NSAttributedString alloc] initWithString:[@(_power) stringValue]
                                                            attributes:@{
                                                                         NSForegroundColorAttributeName:
                                                                             [UIColor colorFromInteger:0xff00ceef],
                                                                         NSFontAttributeName:
                                                                             [UIFont fontWithName:@"HelveticaNeue-Thin" size:100],
                                                                         }];
    [lbPower setAttributedText:s];
   
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    UIRectFill(self.bounds);
    CGFloat width = self.bounds.size.width;
    NSUInteger discreteStepsCount = 512;
    CGFloat innerRadius = width/4, outerRadius = width/2;

    float smallBase= M_PI * innerRadius / discreteStepsCount;
    float largeBase= M_PI * outerRadius / discreteStepsCount;
    
    UIBezierPath * cell = [UIBezierPath bezierPath];
    
    [cell moveToPoint:CGPointMake(-smallBase/2, innerRadius )];
    
    [cell addLineToPoint:CGPointMake(smallBase/2, innerRadius )];
    
    [cell addLineToPoint:CGPointMake(largeBase / 2, outerRadius )];
    [cell addLineToPoint:CGPointMake(-largeBase /2, outerRadius )];
    [cell closePath];
    
    CGFloat incrementalAngle = M_PI / discreteStepsCount;

    CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height * 0.95);
    CGContextTranslateCTM(context, centerPoint.x, centerPoint.y);
    
    CGContextScaleCTM(context, 0.9, 0.9);
    CGContextRotateCTM(context, M_PI / 2);
    CGContextRotateCTM(context,-incrementalAngle/2);
    
    for (NSUInteger i=0; i<discreteStepsCount; i++)
    {
        CGFloat hue = 0.25 * (1 - (CGFloat)i/discreteStepsCount);
        [[UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1] set];
        [cell fill];
        [cell stroke];
        CGContextRotateCTM(context, incrementalAngle);
    }
    
    CGFloat progressAngle = M_PI * ((CGFloat)(_power - _minimumValue) / (_maximumValue - _minimumValue));
    CGPoint p1 = CGPointMake(centerPoint.x - cos(progressAngle - M_PI / 60) * width / 4.6,
                             centerPoint.y - sin(progressAngle - M_PI / 60) * width / 4.6);
    CGPoint p2 = CGPointMake(centerPoint.x - cos(progressAngle + M_PI / 60) * width / 4.6,
                             centerPoint.y - sin(progressAngle + M_PI / 60) * width / 4.6);
    CGPoint p3 = CGPointMake(centerPoint.x - cos(progressAngle - M_PI / 50) * width / 2.7,
                             centerPoint.y - sin(progressAngle - M_PI / 50) * width / 2.7);
    CGPoint p4 = CGPointMake(centerPoint.x - cos(progressAngle + M_PI / 50) * width / 2.7,
                             centerPoint.y - sin(progressAngle + M_PI / 50) * width / 2.7);
    CGPoint p5 = CGPointMake(centerPoint.x - cos(progressAngle) * width / 2.4,
                             centerPoint.y - sin(progressAngle) * width / 2.4);
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
    shapeLayer.strokeColor = [UIColor blackColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    CGPathRelease(path);
    [self.layer addSublayer:shapeLayer];
    

}

- (void)pan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint touchLocation = [panGestureRecognizer locationInView:self];
    CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height * 0.95);
    CGFloat width = self.bounds.size.width;
    CGFloat innerRadius = width/3.6, outerRadius = width/1.8;
    CGFloat distance = hypot(centerPoint.x - touchLocation.x, centerPoint.y - touchLocation.y);
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
