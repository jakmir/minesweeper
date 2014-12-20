//
//  MineGridView.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "MineGridView.h"
#import "MineGridCell.h"
#import "UIColor+ColorFromHexString.h"

#define SLIGHTLY_BIG_VALUEF 1e10;

const NSInteger count = 10;
const NSInteger padding = 19;
const NSInteger spacing = 1;

@implementation MineGridView
{
    NSArray *map;
    CALayer *layer;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self prepareCells];
        [self prepareGradientLayer];        
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self prepareCells];
        [self prepareGradientLayer];
    }
    return self;
}

- (void) prepareGradientLayer
{
    /*
    if (!layer)
    {
        layer = [CALayer layer];
        layer.frame = CGRectMake(padding, padding, CGRectGetWidth(self.frame) - padding * 2 + 1, CGRectGetHeight(self.frame) - padding * 2 + 1);
        layer.position = CGPointMake(CGRectGetWidth(self.frame) / 2 , CGRectGetHeight(self.frame) / 2 - 1);
        layer.backgroundColor = (__bridge CGColorRef)([UIColor colorWithPatternImage:[UIImage imageNamed:@"cell"]]);
    }
    */
    //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"metal2"]];
    self.backgroundColor = [UIColor colorWithRed:0 green:0.3 blue:0.6 alpha:1];
}

- (void) prepareCells
{
    NSMutableArray *columns = [NSMutableArray array];
    
    NSInteger dimensionSize = (self.frame.size.width - 2 * padding - (count - 1) * spacing) / count;
    CGSize size = CGSizeMake(dimensionSize, dimensionSize);
    CGVector offset = CGVectorMake(padding, padding);
    for (int col = 0; col < count; col++)
    {
        NSMutableArray *line = [NSMutableArray array];
        for (int row = 0; row < count; row++)
        {
            CGRect frame = CGRectMake((size.width + spacing) * col + offset.dx, (size.height + spacing) * row + offset.dy, size.width, size.height);
            MineGridCell *mineGridCell = [[MineGridCell alloc] initWithFrame:frame];
            [line addObject:mineGridCell];
            
            [self addSubview:mineGridCell];
        }
        [columns addObject:line];

    }
    
    map = columns;
}

- (void) fillWithMines:(CGFloat)coverageRate exceptPosition:(struct JMSPosition)position
{
    NSInteger quantity = roundf(coverageRate * count * count);
    
    for (int mineNumber = 1; mineNumber <= quantity; mineNumber++)
    {
        BOOL mine;
        NSInteger r, c;
        MineGridCell *mineGridCell;
        do
        {
            r = rand() % count;
            c = rand() % count;
            mineGridCell = map[c][r];
            mine = mineGridCell.mine;
        }
        while (mine || (r == position.row && c == position.column));
        mineGridCell.mine = YES;
        [mineGridCell setNeedsDisplay];
    }
    
    [self evaluateMapCellInfos];
}

- (void) evaluateMapCellInfos
{
    for (int col = 0; col < count; col++)
        for (int row = 0; row < count; row++)
        {
            MineGridCell *cell = map[col][row];
            if (!cell.mine)
            {
                NSUInteger left = 0, right = 0, up = 0, down = 0;
                for (int c = 0; c < count; c++)
                {
                    MineGridCell *checkingCell = map[c][row];
                    if (checkingCell.mine)
                    {
                        if (c < col)
                        {
                            left++;
                        }
                        else
                        {
                            right++;
                        }
                    }
                }
                for (int r = 0; r < count; r++)
                {
                    MineGridCell *checkingCell = map[col][r];
                    if (checkingCell.mine)
                    {
                        if (r < row)
                        {
                            up++;
                        }
                        else
                        {
                            down++;
                        }
                    }
                }
                struct MineGridCellInfo cellInfo;
                cellInfo.minesTopDirection = up;
                cellInfo.minesBottomDirection = down;
                cellInfo.minesLeftDirection = left;
                cellInfo.minesRightDirection = right;
                
                cell.cellInfo = cellInfo;
            }
        }
}

- (NSInteger) cellsCount
{
    return count * count;
}

- (NSInteger) cellsLeftToOpen
{
    NSInteger count = 0;
    for (NSArray *column in map)
    {
        for (MineGridCell *cell in column)
        {
            if (!cell.mine && cell.state != MineGridCellStateOpened)
            {
                count++;
            }
        }
    }
    return count;
}

- (MineGridCell *)cellWithCoordinateInside: (CGPoint)point
{
    MineGridCell *cell = nil;
    struct JMSPosition position = [self cellPositionWithCoordinateInside:point];
    if (position.row != NSNotFound && position.column != NSNotFound)
    {
        cell = map[position.column][position.row];
    }
    
    return cell;
}

- (struct JMSPosition)cellPositionWithCoordinateInside: (CGPoint)point
{
    CGVector offset = CGVectorMake(padding, padding);
    NSInteger dimensionSize = (self.frame.size.width - 2 * padding - (count - 1) * spacing) / count;
    CGPoint relativePoint = CGPointMake(point.x - offset.dx, point.y - offset.dy);
    int col = (int)relativePoint.x / (dimensionSize + spacing);
    int row = (int)relativePoint.y / (dimensionSize + spacing);
    BOOL clickedInField = CGRectContainsPoint(CGRectMake(0, 0, (dimensionSize + spacing) * count, (dimensionSize + spacing) * count), relativePoint);
    BOOL clickedInCell = (int)relativePoint.x % (dimensionSize + spacing) < dimensionSize &&
    (int)relativePoint.y % (dimensionSize + spacing) < dimensionSize;
    
    struct JMSPosition position;
    position.row = NSNotFound;
    position.column = NSNotFound;
    
    if (clickedInField && clickedInCell)
    {
        position.row = row;
        position.column = col;
    }
    
    return position;
}


- (CGFloat)bonus:(struct JMSPosition)position
{
    NSInteger leftBound = position.column, rightBound = position.column;
    NSInteger topBound = position.row, bottomBound = position.row;
    
    BOOL(^isNotOpened)(MineGridCell *) = ^BOOL (MineGridCell *cell)
    {
        return cell && cell.state != MineGridCellStateOpened;
    };
    
    BOOL (^insideGameboard)(NSInteger) = ^BOOL(NSInteger coordinate)
    {
        return coordinate >= 0 && coordinate < count;
    };
    
    MineGridCell *cell;
    do
    {
        leftBound--;
        cell = leftBound >= 0 ? map[leftBound][position.row] : nil;
    }
    while (isNotOpened(cell));
    
    do
    {
        rightBound++;
        cell = rightBound < count ? map[rightBound][position.row] : nil;
    }
    while (isNotOpened(cell));
    
    do
    {
        topBound--;
        cell = topBound >= 0 ? map[position.column][topBound] : nil;
    }
    while (isNotOpened(cell));
    
    do
    {
        bottomBound++;
        cell = bottomBound < count ? map[position.column][bottomBound] : nil;
    }
    while (isNotOpened(cell));
    
    NSLog(@"horizontal: %d <-> %d", leftBound, rightBound);
    NSLog(@"vertical  : %d <-> %d", topBound, bottomBound);
    
    CGFloat a = SLIGHTLY_BIG_VALUEF;
    CGFloat b = SLIGHTLY_BIG_VALUEF;
    
    CGFloat bonus = 0, mines, length;
    MineGridCell *cell1, *cell2;
    
    BOOL leftBoundInside = insideGameboard(leftBound);
    BOOL rightBoundInside = insideGameboard(rightBound);
    BOOL topBoundInside = insideGameboard(topBound);
    BOOL bottomBoundInside = insideGameboard(bottomBound);
    BOOL horizontalLineWithPivot = leftBoundInside || rightBoundInside;
    BOOL verticalLinesWithPivot = topBoundInside || bottomBoundInside;
    
    if (horizontalLineWithPivot)
    {
        length = rightBound - leftBound - 1;
        
        if (!leftBoundInside)
        {
            leftBound = 0;
        }
        if (!rightBoundInside)
        {
            rightBound = count - 1;
        }

        cell1 = map[leftBound][position.row];
        cell2 = map[rightBound][position.row];
        mines = rightBoundInside ? cell2.cellInfo.minesLeftDirection - cell1.cellInfo.minesLeftDirection
                                 : cell1.cellInfo.minesRightDirection - cell2.cellInfo.minesRightDirection;
        
        if (mines > 0)
        {
            a = length/mines;
        }
    }
    
    if (verticalLinesWithPivot)
    {
        length = bottomBound - topBound - 1;
        
        if (!topBoundInside)
        {
            topBound = 0;
        }
        if (!bottomBoundInside)
        {
            bottomBound = count - 1;
        }

        cell1 = map[position.column][topBound];
        cell2 = map[position.column][bottomBound];
        mines = bottomBoundInside ? cell2.cellInfo.minesTopDirection - cell1.cellInfo.minesTopDirection
                                  : cell1.cellInfo.minesBottomDirection - cell2.cellInfo.minesBottomDirection;
        
        if (mines > 0)
        {
            b = length/mines;
        }
    }
    
    if (horizontalLineWithPivot)
    {
        if (verticalLinesWithPivot)
        {
            bonus = 1 / (2 + a * b - a - b);
        }
        else
        {
            bonus = 1/a;
        }
    }
    else
    {
        if (verticalLinesWithPivot)
        {
            bonus = 1/b;
        }
    }
    return fabsf(bonus) < 1e-4 ? 0 : bonus;
}

- (MineGridCellState) cellState:(struct JMSPosition)position
{
    MineGridCell *cell = map[position.column][position.row];
    if (cell)
    {
        return cell.state;
    }
    return MineGridCellStateClosed;
}

- (BOOL) clickedWithCoordinate: (CGPoint)point
{
    MineGridCell *cell = [self cellWithCoordinateInside:point];
    
    if (cell)
    {
        [cell setState:MineGridCellStateOpened];
        return cell.mine;
    }
    
    return NO;
}

- (void) longTappedWithCoordinate:(CGPoint)point
{
    MineGridCell *cell = [self cellWithCoordinateInside:point];
    
    if (cell)
    {
        switch (cell.state)
        {
            case MineGridCellStateMarked:
                [cell setState:MineGridCellStateClosed];
                break;
            case MineGridCellStateClosed:
                [cell setState:MineGridCellStateMarked];
                break;
            default:
                break;
        }
    }
}


- (void)drawRect:(CGRect)rect
{
    NSLog(@"%s", __FUNCTION__);
    
    [super drawRect:rect];
    
}


@end
