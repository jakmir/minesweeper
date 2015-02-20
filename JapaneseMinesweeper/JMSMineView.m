//
//  JMSMineView.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/18/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSMineView.h"
#import "UIColor+ColorFromHexString.h"

@implementation JMSMineView
{
    CAGradientLayer *layer;
    
}
- (void)drawRect:(CGRect)rect
{
    NSLog(@"%s", __FUNCTION__);
    
    CGColorRef fillColor = [UIColor lightGrayColor].CGColor;
    
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor clearColor] setFill];    
    CGContextFillRect(ctx, rect);

    CGFloat bigarr[8] = {0, 45, 90, 135, 180, 225, 270, 315};
    CGFloat smallarr[8] = {
                            (bigarr[0] + bigarr[1]) / 2,
                            (bigarr[1] + bigarr[2]) / 2,
                            (bigarr[2] + bigarr[3]) / 2,
                            (bigarr[3] + bigarr[4]) / 2,
                            (bigarr[4] + bigarr[5]) / 2,
                            (bigarr[5] + bigarr[6]) / 2,
                            (bigarr[6] + bigarr[7]) / 2,
                            (bigarr[7] + 360) / 2
                            };
        
   
    CGFloat radius = self.bounds.size.width * 0.3;
    CGFloat d = self.bounds.size.width * 0.4;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGPoint c = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGFloat db = 8, ds = 4;
    
    
    for (int i=0; i<=7; i++)
    {
        CGFloat a1 = (bigarr[i] + db) * M_PI / 180;
        CGFloat a2 = (smallarr[i] - ds) * M_PI / 180;
        CGFloat a3 = (smallarr[i] + ds) * M_PI / 180;
        CGFloat a21 = (smallarr[i] - ds * 0.78) * M_PI / 180;
        CGFloat a31 = (smallarr[i] + ds * 0.78) * M_PI / 180;
        CGFloat a4 = (bigarr[(i+1)%8] - db) * M_PI / 180;
        CGFloat a41 = (bigarr[(i+1)%8] - db * 0.74) * M_PI / 180;
        CGFloat a51 = (bigarr[(i+1)%8] + db * 0.74) * M_PI / 180;
        [bezierPath addArcWithCenter:c radius:radius startAngle:a1 endAngle:a2 clockwise:YES];
        [bezierPath addArcWithCenter:c radius:d*0.85 startAngle:a21 endAngle:a31 clockwise:YES];
        [bezierPath addArcWithCenter:c radius:radius startAngle:a3 endAngle:a4 clockwise:YES];
        [bezierPath addArcWithCenter:c radius:d startAngle:a41 endAngle:a51 clockwise:YES];
        
    }
    [bezierPath fill];
    [bezierPath stroke];
    [bezierPath closePath];
    
    CAShapeLayer *lyr = [CAShapeLayer layer];
    lyr.path = bezierPath.CGPath;
    lyr.fillColor = fillColor;
    [self.layer addSublayer:lyr];
    
    
    for (int i=0; i<=7; i++)
    {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        CGMutablePathRef path = CGPathCreateMutable();
        CGPoint cp1 = CGPointMake(c.x + cos(2 * M_PI - bigarr[i] * M_PI / 180) * d, c.y - sin(2 * M_PI - bigarr[i] * M_PI / 180) * d);
        
        CGPathAddArc(path, NULL, cp1.x, cp1.y, 42.3, 0, M_PI*2, YES);
        CGPathCloseSubpath(path);
        
        shapeLayer.path = path;
        shapeLayer.strokeColor = fillColor;
        shapeLayer.fillColor = fillColor;
        CGPathRelease(path);
        
        [self.layer addSublayer:shapeLayer];
    }
    
    for (int i=0; i<=7; i++)
    {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        CGMutablePathRef path = CGPathCreateMutable();
        CGPoint cp1 = CGPointMake(c.x + cos(2 * M_PI - smallarr[i] * M_PI / 180) * d*0.85, c.y - sin(2 * M_PI - smallarr[i] * M_PI / 180) * d*0.85);
        
        CGPathAddArc(path, NULL, cp1.x, cp1.y, 19, 0, M_PI*2, YES);
        CGPathCloseSubpath(path);
        
        shapeLayer.path = path;
        shapeLayer.strokeColor = fillColor;
        shapeLayer.fillColor = fillColor;
        CGPathRelease(path);
        [self.layer addSublayer:shapeLayer];
    }
    if (!layer)
    {
        layer = [CAGradientLayer layer];
        layer.frame = rect;
        layer.startPoint = CGPointMake(0.5, 0.0);
        layer.endPoint = CGPointMake(0.5, 1.0);
        layer.position = CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetHeight(rect) / 2);
        
        [self.layer insertSublayer:layer atIndex:0];
    }
    

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
