//
//  JMSGradientSpeedmeterView.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/16/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSGradientSpeedmeterView.h"
#import "UIColor+ColorFromHexString.h"

@interface JMSGradientSpeedmeterView()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UILabel *lbPower;

@end

@implementation JMSGradientSpeedmeterView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _minimumValue = 0;
        _maximumValue = UINT32_MAX;
        _power = 0;
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOrTap:)];
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panOrTap:)];
        [self addGestureRecognizer:self.panGestureRecognizer];
        [self addGestureRecognizer:self.tapGestureRecognizer];
        
        [self initialize];
    }
    return self;
}

- (void)initialize {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:128];
    label.textColor = [UIColor colorFromInteger:0xffcfcfcf];
    
    [self addSubview:label];

    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0f constant:0.f];
    
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0f constant:0.f];
    
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0f constant:0.f];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:0
                                                               constant:128];
    [self addConstraints:@[leading, trailing, bottom]];
    [label addConstraint:height];
    
    self.lbPower = label;
    
}
- (void)dealloc {
    [self removeGestureRecognizer:self.panGestureRecognizer];
    [self removeGestureRecognizer:self.tapGestureRecognizer];
}

- (void)setMinimumValue:(NSUInteger)minimumValue {
    _minimumValue = minimumValue;
    if (_minimumValue >= _maximumValue) {
        _minimumValue = _maximumValue - 1;
    }
}

- (void)setMaximumValue:(NSUInteger)maximumValue {
    _maximumValue = maximumValue;
    if (_maximumValue <= _minimumValue) {
        _maximumValue = _minimumValue + 1;
    }
}

- (void)setPower:(NSUInteger)power {
    _power = MAX(_minimumValue, MIN(power, _maximumValue));
    [self setNeedsDisplay];
    [self.lbPower setText:[@(power) stringValue]];
   
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    UIRectFill(self.bounds);
    CGFloat width = self.bounds.size.width;
    NSUInteger discreteStepsCount = 256;
    CGFloat innerRadius = width / 4, outerRadius = width / 2;

    float smallBase = M_PI * innerRadius / discreteStepsCount;
    float largeBase = M_PI * outerRadius / discreteStepsCount;
    
    UIBezierPath * cell = [UIBezierPath bezierPath];
    
    [cell moveToPoint:CGPointMake(-smallBase / 2, innerRadius )];
    
    [cell addLineToPoint:CGPointMake(smallBase / 2, innerRadius )];
    
    [cell addLineToPoint:CGPointMake(largeBase / 2, outerRadius )];
    [cell addLineToPoint:CGPointMake(-largeBase / 2, outerRadius )];
    [cell closePath];
    
    NSUInteger extraSteps = 20;
    CGFloat incrementalAngle = M_PI / discreteStepsCount;

    CGPoint anchorPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height * 0.95);
    CGContextTranslateCTM(context, anchorPoint.x, anchorPoint.y);
    
    CGContextScaleCTM(context, 0.9, 0.9);
    CGContextRotateCTM(context, M_PI / 2 - M_PI / extraSteps);
    CGContextRotateCTM(context, -incrementalAngle/2);
    
    NSUInteger totalSteps = discreteStepsCount + extraSteps * 3;
    for (NSUInteger i = 0; i < totalSteps; i++) {
        CGFloat hue = 0.25 * (1 - (CGFloat)i / totalSteps);
        [[UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1] set];
        [cell fill];
        [cell stroke];
        CGContextRotateCTM(context, incrementalAngle);
    }
    
    CGFloat progressAngle = M_PI * ((CGFloat)(_power - _minimumValue) / (_maximumValue - _minimumValue));
    CGFloat arrowBaseAngleStart = progressAngle - M_PI / 60, arrowBaseAngleEnd = progressAngle + M_PI / 60;
    CGFloat arrowPointerAngleStart = progressAngle - M_PI / 52, arrowPointerAngleEnd = progressAngle + M_PI / 52;
    CGFloat arrowBasePolarDistance = innerRadius * 0.89f;
    CGFloat arrowPointerPolarDistance = outerRadius * 0.80f;
    CGFloat arrowNeedlePolarDistance = outerRadius * 0.875f;
    CGPoint arrowBasePoint1 = CGPointMake(anchorPoint.x - cos(arrowBaseAngleStart) * arrowBasePolarDistance,
                                          anchorPoint.y - sin(arrowBaseAngleStart) * arrowBasePolarDistance);
    CGPoint arrowBasePoint2 = CGPointMake(anchorPoint.x - cos(arrowBaseAngleEnd) * arrowBasePolarDistance,
                                          anchorPoint.y - sin(arrowBaseAngleEnd) * arrowBasePolarDistance);
    CGPoint arrowPointerLeft = CGPointMake(anchorPoint.x - cos(arrowPointerAngleStart) * arrowPointerPolarDistance,
                                           anchorPoint.y - sin(arrowPointerAngleStart) * arrowPointerPolarDistance);
    CGPoint arrowPointerRight = CGPointMake(anchorPoint.x - cos(arrowPointerAngleEnd) * arrowPointerPolarDistance,
                                            anchorPoint.y - sin(arrowPointerAngleEnd) * arrowPointerPolarDistance);
    CGPoint needlePoint = CGPointMake(anchorPoint.x - cos(progressAngle) * arrowNeedlePolarDistance,
                                      anchorPoint.y - sin(progressAngle) * arrowNeedlePolarDistance);
    if (self.shapeLayer != nil) {
        [self.shapeLayer removeFromSuperlayer];
    }
    
    self.shapeLayer = [CAShapeLayer layer];
    CGMutablePathRef path = CGPathCreateMutable();

    CGPathMoveToPoint(path, nil, arrowBasePoint1.x, arrowBasePoint1.y);
    CGPathAddLineToPoint(path, nil, arrowBasePoint2.x, arrowBasePoint2.y);
    CGPathAddLineToPoint(path, nil, arrowPointerRight.x, arrowPointerRight.y);
    CGPathAddLineToPoint(path, nil, needlePoint.x, needlePoint.y);
    CGPathAddLineToPoint(path, nil, arrowPointerLeft.x, arrowPointerLeft.y);
    CGPathCloseSubpath(path);
    
    self.shapeLayer.path = path;
    self.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.shapeLayer.fillColor = [UIColor needleColor].CGColor;
    self.shapeLayer.lineWidth = 2;
    CGPathRelease(path);
    
    [self.layer addSublayer:self.shapeLayer];
}

- (void)panOrTap:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint touchLocation = [gestureRecognizer locationInView:self];
    CGPoint centerPoint = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height * 0.95);
    CGFloat width = self.bounds.size.width;
    CGFloat innerRadius = width/(4/0.9), outerRadius = width/(2/0.9);
    CGFloat distance = hypot(centerPoint.x - touchLocation.x, MAX(centerPoint.y - touchLocation.y, 0));
    BOOL isWithinArc = distance >= innerRadius && distance <= outerRadius && touchLocation.y < centerPoint.y / 0.95;
    if (!isWithinArc) {
        return;
    }
    
    CGFloat mirroredAngle = acos((touchLocation.x - centerPoint.x) / distance);

    NSUInteger power = lround((1 - mirroredAngle / M_PI) * (_maximumValue - _minimumValue) + _minimumValue);

    if (_power != power) {
        [self setPower:power];
        if ([self.delegate respondsToSelector:@selector(didSpeedmeterValueChange:value:)]) {
            [self.delegate didSpeedmeterValueChange:self value:power];
        }
    }
}


@end
