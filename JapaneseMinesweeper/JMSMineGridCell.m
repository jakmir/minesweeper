//
//  MineGridCell.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "JMSMineGridCell.h"
#import "Classes/JMSMineGridCellInfo.h"
#import "UIColor+ColorFromHexString.h"

@implementation JMSMineGridCell
{
    CAGradientLayer *gradientLayer;
    CALayer *blurLayer;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _state = MineGridCellStateClosed;
    }
    return self;
}

- (UIColor *)colorForNeighbourInfoNumber:(NSUInteger)number
{
    switch (number)
    {
        case 0: return [UIColor colorFromInteger:0xff00af00];
        case 1: return [UIColor colorFromInteger:0xff69af00];
        case 2: return [UIColor colorFromInteger:0xffb1cc00];
        case 3: return [UIColor colorFromInteger:0xffcc7f00];
        case 4: return [UIColor colorFromInteger:0xffff6600];
        default: return [UIColor colorFromInteger:0xffbf2222];
    }
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSLog(@"%s", __FUNCTION__);
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
    CGContextSetRGBStrokeColor(context, 0.8, 0.9, 0.9, 0.8);
    CGContextSetLineWidth(context, 1.0);
    
    self.backgroundColor = [UIColor clearColor];
    
    switch (self.state)
    {
        case MineGridCellStateClosed:
        {
            CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1);
            CGContextFillRect(context, rectangle);
            self.alpha = 0.75;
        }
            break;
        case MineGridCellStateMarked:
        {
            CGContextSetRGBFillColor(context, 1, 1, 1, 0.75);
            CGContextFillRect(context, rectangle);
            self.layer.contents = (__bridge id)([UIImage imageNamed:@"flag"].CGImage);
            
            self.alpha = 1;
        }
            break;
        case MineGridCellStateOpened:
        {
            self.alpha = 1;

            CGContextClearRect(context, rectangle);
            CGContextSetRGBFillColor(context, 0.9, 0.9, 0.9, 0.5);
            CGContextFillRect(context, rectangle);

            UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:self.mine ? 90 : 20];
            UIColor* textColor = [UIColor colorWithRed:0 green:0.7 * 0.6 blue:0.9 * 0.6 alpha:1];
            
            if (self.mine)
            {
                [@"*" drawAtPoint:CGPointMake(19.f, 1.f) withAttributes:@{
                                                                          NSFontAttributeName: font,
                                                                          NSForegroundColorAttributeName:[UIColor whiteColor]
                                                                          }];
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
                [[@(self.cellInfo.minesLeftDirection) stringValue] drawAtPoint:CGPointMake(7, 22)
                                                                withAttributes:@{
                                                                                 NSFontAttributeName: font,
                                                                                 NSForegroundColorAttributeName:[self colorForNeighbourInfoNumber:self.cellInfo.minesLeftDirection]
                                                                                 }];
                [[@(self.cellInfo.minesRightDirection) stringValue] drawAtPoint:CGPointMake(54, 22)
                                                                 withAttributes:@{
                                                                                  NSFontAttributeName: font,
                                                                                  NSForegroundColorAttributeName:[self colorForNeighbourInfoNumber:self.cellInfo.minesRightDirection]
                                                                                  }];
                [[@(self.cellInfo.minesTopDirection) stringValue] drawAtPoint:CGPointMake(31, 2)
                                                               withAttributes:@{
                                                                                NSFontAttributeName: font,
                                                                                NSForegroundColorAttributeName:[self colorForNeighbourInfoNumber:self.cellInfo.minesTopDirection]
                                                                                }];
                [[@(self.cellInfo.minesBottomDirection) stringValue] drawAtPoint:CGPointMake(31, 44)
                                                                  withAttributes:@{
                                                                                   NSFontAttributeName: font,
                                                                                   NSForegroundColorAttributeName:[self colorForNeighbourInfoNumber:self.cellInfo.minesBottomDirection]
                                                                                   }];

            }
        }
            break;
        default:
            break;
    }
}

- (void) setState:(JMSMineGridCellState)state
{
    if (_state != state)
    {
        _state = state;
        [self setNeedsDisplay];
    }
}

- (JMSMineGridCellInfo *)exportCell
{
    JMSMineGridCellInfo *result = [JMSMineGridCellInfo new];
    result.mine = self.mine;
    result.state = self.state;
    result.cellInfo = self.cellInfo;
    return result;
}

- (void)import:(JMSMineGridCellInfo *)mineGridCellInfo
{
    _mine = mineGridCellInfo.mine;
    _cellInfo = mineGridCellInfo.cellInfo;
    _state = mineGridCellInfo.state;
}
@end
