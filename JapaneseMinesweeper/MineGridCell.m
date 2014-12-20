//
//  MineGridCell.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "MineGridCell.h"

@implementation MineGridCell
{
    CAGradientLayer *gradientLayer;
    CALayer *blurLayer;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.state = MineGridCellStateClosed;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    /*
    if (!blurLayer)
    {
        blurLayer = [CALayer layer];
        blurLayer.frame = rect;
        CIFilter *blur = [CIFilter filterWithName:@"CIGaussianBlur"];
        [blur setDefaults];
        blurLayer.backgroundFilters = [NSArray arrayWithObject:blur];
        
        self.layer.mask = blurLayer;
    }
    */
    
    CGRect rectangle = rect;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 0.9, 0.9, 0.9, 1);
    CGContextSetLineWidth(context, 1.0);
    
    self.backgroundColor = [UIColor clearColor];
    
    switch (self.state)
    {
        case MineGridCellStateClosed:
        {
            CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1);
            CGContextFillRect(context, rectangle);
            self.alpha = 0.5;
        }
            break;
        case MineGridCellStateMarked:
        {
            CGContextSetRGBFillColor(context, 0.3, 0.5, 0.3, 1);
            CGContextFillRect(context, rectangle);
            
            self.layer.contents = (__bridge id)([UIImage imageNamed:@"flag"].CGImage);
            
            self.alpha = 1;
        }
            break;
        case MineGridCellStateOpened:
        {
            self.alpha = 1;

            CGContextClearRect(context, rectangle);
            CGContextSetRGBFillColor(context, 1, 1, 1, 0.2);
            CGContextFillRect(context, rectangle);
            UIFont* font = [UIFont systemFontOfSize:self.mine ? 90 : 20];
            UIColor* textColor = [UIColor lightTextColor];
            NSDictionary* stringAttrs = @{NSFontAttributeName: font, NSForegroundColorAttributeName:textColor};
            
            if (self.mine)
            {
                [@"*" drawAtPoint:CGPointMake(19.f, 1.f) withAttributes:stringAttrs];
            }
            else
            {
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, 0, 0);
                CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
                CGContextMoveToPoint(context, rect.size.width, 0);
                CGContextAddLineToPoint(context, 0, rect.size.height);
                CGContextClosePath(context);
                CGContextDrawPath(context, kCGPathFillStroke);
                [[@(self.cellInfo.minesLeftDirection) stringValue] drawAtPoint:CGPointMake(7, 22) withAttributes:stringAttrs];
                [[@(self.cellInfo.minesRightDirection) stringValue] drawAtPoint:CGPointMake(54, 22) withAttributes:stringAttrs];
                [[@(self.cellInfo.minesTopDirection) stringValue] drawAtPoint:CGPointMake(31, 2) withAttributes:stringAttrs];
                [[@(self.cellInfo.minesBottomDirection) stringValue] drawAtPoint:CGPointMake(31, 44) withAttributes:stringAttrs];
            }
        }
            break;
        default:
            break;
    }
}

- (void) setState:(MineGridCellState)state
{
    if (_state != state)
    {
        _state = state;
        [self setNeedsDisplay];
    }
}

@end
