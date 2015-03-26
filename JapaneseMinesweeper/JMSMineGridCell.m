//
//  MineGridCell.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "JMSMineGridCell.h"
#import "JMSMineGridView.h"
#import "Classes/JMSMineGridCellInfo.h"
#import "UIColor+ColorFromHexString.h"

@interface JMSMineGridCell()

@end

@implementation JMSMineGridCell
{
    CAGradientLayer *gradientLayer;
    CAShapeLayer *antLayer;
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
    
    CGRect rectangle = rect;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    self.backgroundColor = [UIColor clearColor];
    
    switch (self.state)
    {
        case MineGridCellStateClosed:
        {
            CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1);
            CGContextFillRect(context, rectangle);
            if (self.mineGridView.gameFinished && self.mine)
            {
                [[UIImage imageNamed:@"mine"] drawInRect:rectangle];
            }
        }
            break;
        case MineGridCellStateMarked:
        {
            CGContextClearRect(context, rectangle);
            CGContextSetRGBFillColor(context, 0.9, 0.9, 0.9, 0.5);
            CGContextFillRect(context, rectangle);
            if (!self.mineGridView.gameFinished || self.mine)
            {
                [[UIImage imageNamed:@"flag"] drawInRect:rectangle];
            }
            else
            {
                [[UIImage imageNamed:@"mine"] drawInRect:rectangle];
                CGFloat padding = 8;
                    
                CGContextSetRGBStrokeColor(context, 1, 0.4, 0, 1);
                CGContextSetLineWidth(context, 12.0);
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, padding, padding);
                CGContextAddLineToPoint(context, rect.size.width - padding, rect.size.height - padding);
                CGContextMoveToPoint(context, rect.size.width - padding, padding);
                CGContextAddLineToPoint(context, padding, rect.size.height - padding);
                CGContextClosePath(context);
                CGContextDrawPath(context, kCGPathFillStroke);
            }
        }
            break;
        case MineGridCellStateOpened:
        {
            CGContextClearRect(context, rectangle);
            CGContextSetRGBFillColor(context, 0.9, 0.9, 0.9, 0.5);
            CGContextFillRect(context, rectangle);
            if (self.mine)
            {
                [[UIImage imageNamed:@"currentMine"] drawInRect:rectangle];
            }
            else
            {
                CGContextSetRGBStrokeColor(context, 0.8, 0.9, 0.9, 0.8);
                CGContextSetLineWidth(context, 1.0);
                UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
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
