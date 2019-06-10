//
//  MineGridCell.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "JMSMineGridCell.h"
#import "JMSMineGridView.h"
#import "JMSMineGridCellInfo.h"
#import "UIColor+ColorFromHexString.h"

@implementation JMSMineGridCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _state = MineGridCellStateClosed;
    }
    return self;
}

- (UIColor *)colorWithMinesAheadNumber:(NSUInteger)number {
    switch (number) {
        case 0: return [UIColor colorFromInteger:0xff00af00];
        case 1: return [UIColor colorFromInteger:0xff69af00];
        case 2: return [UIColor colorFromInteger:0xffb1cc00];
        case 3: return [UIColor colorFromInteger:0xffcc7f00];
        case 4: return [UIColor colorFromInteger:0xffff6600];
        default: return [UIColor colorFromInteger:0xffbf2222];
    }
}

- (void)drawForClosedStateWithContext:(CGContextRef)context rect:(CGRect)rect {
    CGContextSetRGBFillColor(context, 0.8, 0.8, 0.8, 1);
    CGContextFillRect(context, rect);
}

- (void)drawForMarkedMistakenlyStateWithContext:(CGContextRef)context rect:(CGRect)rect {
    CGContextClearRect(context, rect);
    CGContextSetRGBFillColor(context, 0.9, 0.9, 0.9, 0.5);
    CGContextFillRect(context, rect);
    
    [[UIImage imageNamed:@"mine"] drawInRect:rect];
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

- (void)drawForMarkedStateWithContext:(CGContextRef)context rect:(CGRect)rect {
    CGContextClearRect(context, rect);
    CGContextSetRGBFillColor(context, 0.9, 0.9, 0.9, 0.5);
    CGContextFillRect(context, rect);

    [[UIImage imageNamed:@"flag"] drawInRect:rect];
}

- (void)drawForOpenedOrDisclosedStateWithContext:(CGContextRef)context
                                            rect:(CGRect)rect
                                  openedByPlayer:(BOOL)openedByPlayer {
    CGContextClearRect(context, rect);
    CGContextSetRGBFillColor(context, 0.9, 0.9, 0.9, 0.5);
    CGContextFillRect(context, rect);
    if (self.mine) {
        if (openedByPlayer) {
            [[UIImage imageNamed:@"currentMine"] drawInRect:rect];
        } else {
            [[UIImage imageNamed:@"mine"] drawInRect:rect];
        }
        return;
    }

    CGContextSetRGBStrokeColor(context, 0.8, 0.9, 0.9, 0.8);
    CGContextSetLineWidth(context, 1.0);
    UIFont *font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextMoveToPoint(context, rect.size.width, 0);
    CGContextAddLineToPoint(context, 0, rect.size.height);
        
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    NSUInteger minesLeft = self.cellInfo.minesLeftDirection;
    NSUInteger minesRight = self.cellInfo.minesRightDirection;
    NSUInteger minesTop = self.cellInfo.minesTopDirection;
    NSUInteger minesBottom = self.cellInfo.minesBottomDirection;
    
    [[@(minesLeft) stringValue] drawAtPoint:CGPointMake(7, 22)
                             withAttributes:@{
                                                NSFontAttributeName: font,
                                                NSForegroundColorAttributeName:[self colorWithMinesAheadNumber:minesLeft]
                                             }];
    [[@(minesRight) stringValue] drawAtPoint:CGPointMake(54, 22)
                              withAttributes:@{
                                                NSFontAttributeName: font,
                                                NSForegroundColorAttributeName:[self colorWithMinesAheadNumber:minesRight]
                                              }];
    [[@(minesTop) stringValue] drawAtPoint:CGPointMake(31, 2)
                            withAttributes:@{
                                                NSFontAttributeName: font,
                                                NSForegroundColorAttributeName:[self colorWithMinesAheadNumber:minesTop]
                                            }];
    [[@(minesBottom) stringValue] drawAtPoint:CGPointMake(31, 44)
                               withAttributes:@{
                                                NSFontAttributeName: font,
                                                NSForegroundColorAttributeName:[self colorWithMinesAheadNumber:minesBottom]
                                               }];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    self.backgroundColor = [UIColor clearColor];
    
    switch (self.state) {
        case MineGridCellStateClosed:
            [self drawForClosedStateWithContext:context rect:rect];
            break;
        case MineGridCellStateMarked:
            [self drawForMarkedStateWithContext:context rect:rect];
            break;
        case MineGridCellStateOpened:
            [self drawForOpenedOrDisclosedStateWithContext:context rect:rect
                                            openedByPlayer:YES];
            break;
        case MineGridCellStateMarkedMistakenly:
            [self drawForMarkedMistakenlyStateWithContext:context rect:rect];
            break;
        case MineGridCellStateDisclosed:
            [self drawForOpenedOrDisclosedStateWithContext:context rect:rect
                                            openedByPlayer:NO];
            break;
    }
}

- (void)setState:(JMSMineGridCellState)state {
    if (_state != state) {
        _state = state;
        [self setNeedsDisplay];
    }
}

- (JMSMineGridCellInfo *)exportCell {
    JMSMineGridCellInfo *result = [JMSMineGridCellInfo new];
    result.mine = self.mine;
    result.state = self.state;
    result.cellInfo = self.cellInfo;
    return result;
}

- (void)importFromCellInfo:(JMSMineGridCellInfo *)mineGridCellInfo {
    _mine = mineGridCellInfo.mine;
    _cellInfo = mineGridCellInfo.cellInfo;
    _state = mineGridCellInfo.state;
}

@end
