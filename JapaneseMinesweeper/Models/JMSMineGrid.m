//
//  JMSMineGrid.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/21/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSMineGrid.h"
#import "JMSMineGridCell.h"

#define SLIGHTLY_BIG_VALUEF 1e10;

@implementation JMSMineGrid

- (NSInteger)rowCount
{
    NSArray *row = self.map.firstObject;
    return row ? row.count : 0;
}

- (NSInteger)colCount
{
    return self.map.count;
}

- (BOOL)mineAtPosition:(struct JMSPosition)position
{
    JMSMineGridCell *cell = self.map[position.column][position.row];
    return cell.mine;
}

- (void) fillMapWithLevel:(NSUInteger)level exceptPosition:(struct JMSPosition)position
{
    for (int mineNumber = 1; mineNumber <= level; mineNumber++)
    {
        BOOL mine;
        NSInteger r, c;
        JMSMineGridCell *mineGridCell;
        do
        {
            r = rand() % self.rowCount;
            c = rand() % self.colCount;
            mineGridCell = self.map[c][r];
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
    for (int col = 0; col < self.colCount; col++)
        for (int row = 0; row < self.rowCount; row++)
        {
            JMSMineGridCell *cell = self.map[col][row];
            if (!cell.mine)
            {
                NSUInteger left = 0, right = 0, up = 0, down = 0;
                for (int c = 0; c < self.colCount; c++)
                {
                    JMSMineGridCell *checkingCell = self.map[c][row];
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
                for (int r = 0; r < self.rowCount; r++)
                {
                    JMSMineGridCell *checkingCell = self.map[col][r];
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
                struct JMSMineGridCellNeighboursSummary cellInfo;
                cellInfo.minesTopDirection = up;
                cellInfo.minesBottomDirection = down;
                cellInfo.minesLeftDirection = left;
                cellInfo.minesRightDirection = right;
                
                cell.cellInfo = cellInfo;
            }
        }
}

- (NSInteger) cellsLeftToOpen
{
    NSInteger count = 0;
    for (NSArray *column in self.map)
    {
        for (JMSMineGridCell *cell in column)
        {
            if (!cell.mine && cell.state != MineGridCellStateOpened)
            {
                count++;
            }
        }
    }
    return count;
}

- (CGFloat)bonus:(struct JMSPosition)position
{
    NSInteger leftBound = position.column, rightBound = position.column;
    NSInteger topBound = position.row, bottomBound = position.row;
    
    BOOL(^isNotOpened)(JMSMineGridCell *) = ^BOOL (JMSMineGridCell *cell)
    {
        return cell && cell.state != MineGridCellStateOpened;
    };
    
    BOOL (^xinsideGameboard)(NSInteger) = ^BOOL(NSInteger coordinate)
    {
        return coordinate >= 0 && coordinate < self.colCount;
    };

    BOOL (^yinsideGameboard)(NSInteger) = ^BOOL(NSInteger coordinate)
    {
        return coordinate >= 0 && coordinate < self.rowCount;
    };
    
    JMSMineGridCell *cell;
    do
    {
        leftBound--;
        cell = leftBound >= 0 ? self.map[leftBound][position.row] : nil;
    }
    while (isNotOpened(cell));
    
    do
    {
        rightBound++;
        cell = rightBound < self.colCount ? self.map[rightBound][position.row] : nil;
    }
    while (isNotOpened(cell));
    
    do
    {
        topBound--;
        cell = topBound >= 0 ? self.map[position.column][topBound] : nil;
    }
    while (isNotOpened(cell));
    
    do
    {
        bottomBound++;
        cell = bottomBound < self.rowCount ? self.map[position.column][bottomBound] : nil;
    }
    while (isNotOpened(cell));
    
    NSLog(@"horizontal: %d <-> %d", leftBound, rightBound);
    NSLog(@"vertical  : %d <-> %d", topBound, bottomBound);
    
    CGFloat a = SLIGHTLY_BIG_VALUEF;
    CGFloat b = SLIGHTLY_BIG_VALUEF;
    
    CGFloat bonus = 0, mines, length;
    JMSMineGridCell *cell1, *cell2;
    
    BOOL leftBoundInside = xinsideGameboard(leftBound);
    BOOL rightBoundInside = xinsideGameboard(rightBound);
    BOOL topBoundInside = yinsideGameboard(topBound);
    BOOL bottomBoundInside = yinsideGameboard(bottomBound);
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
            rightBound = self.colCount - 1;
        }
        
        cell1 = self.map[leftBound][position.row];
        cell2 = self.map[rightBound][position.row];
        mines = rightBoundInside
                    ? cell2.cellInfo.minesLeftDirection - cell1.cellInfo.minesLeftDirection
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
            bottomBound = self.rowCount - 1;
        }
        
        cell1 = self.map[position.column][topBound];
        cell2 = self.map[position.column][bottomBound];
        mines = bottomBoundInside
                    ? cell2.cellInfo.minesTopDirection - cell1.cellInfo.minesTopDirection
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

- (JMSMineGridCellState) cellState:(struct JMSPosition)position
{
    JMSMineGridCell *cell = self.map[position.column][position.row];
    if (cell)
    {
        return cell.state;
    }
    return MineGridCellStateClosed;
}

- (NSInteger)markMines
{
    NSInteger markedCellsCount = 0;
    for (NSArray *column in self.map)
    {
        for (JMSMineGridCell *cell in column)
        {
            if (cell.mine && cell.state != MineGridCellStateMarked)
            {
                [cell setState:MineGridCellStateMarked];
                markedCellsCount++;
            }
        }
    }
    return markedCellsCount;
}

- (BOOL)openInZeroDirectionsFromPosition:(struct JMSPosition)position
                           unmarkedCount:(NSUInteger *)unmarkedCount
                             openedCount:(NSUInteger *)openedCount
{
    NSUInteger unmarkedCells = 0;
    NSUInteger openedCells = 0;
    
    JMSMineGridCell *cell = self.map[position.column][position.row];
    if (cell.state == MineGridCellStateOpened)
    {
        *unmarkedCount = 0;
        *openedCount = 0;
        return NO;
    }
    NSMutableArray *floodMap = [NSMutableArray array];
    for (NSUInteger col = 0; col < self.colCount; col++)
    {
        NSMutableArray *floodColumn = [NSMutableArray array];
        for (NSUInteger row = 0; row < self.rowCount; row++)
        {
            [floodColumn addObject:@(UINT32_MAX)];
        }
        [floodMap addObject:floodColumn];
    }
    
    floodMap[position.column][position.row] = @(0);
    
    void (^checkLeftCell)(struct JMSPosition) = ^(struct JMSPosition pos)
    {
        JMSMineGridCell *thisCell = self.map[pos.column][pos.row];
        NSUInteger thisValue = [floodMap[pos.column][pos.row] integerValue];
        if (thisValue < UINT32_MAX && pos.column > 0 && thisCell.cellInfo.minesLeftDirection == 0)
        {
            JMSMineGridCell *neighbourCell = self.map[pos.column - 1][pos.row];
            if (neighbourCell.state != MineGridCellStateOpened)
            {
                floodMap[pos.column - 1][pos.row] = @(MIN([floodMap[pos.column - 1][pos.row] integerValue], thisValue + 1));
            }
        }
    };
    void (^checkRightCell)(struct JMSPosition) = ^(struct JMSPosition pos)
    {
        JMSMineGridCell *thisCell = self.map[pos.column][pos.row];
        NSUInteger thisValue = [floodMap[pos.column][pos.row] integerValue];
        if (thisValue < UINT32_MAX && pos.column < self.colCount-1 && thisCell.cellInfo.minesRightDirection == 0)
        {
            JMSMineGridCell *neighbourCell = self.map[pos.column + 1][pos.row];
            if (neighbourCell.state != MineGridCellStateOpened)
            {
                floodMap[pos.column + 1][pos.row] = @(MIN([floodMap[pos.column + 1][pos.row] integerValue], thisValue + 1));
            }
        }
    };
    void (^checkUpperCell)(struct JMSPosition) = ^(struct JMSPosition pos)
    {
        JMSMineGridCell *thisCell = self.map[pos.column][pos.row];
        NSUInteger thisValue = [floodMap[pos.column][pos.row] integerValue];
        if (thisValue < UINT32_MAX && pos.row > 0 && thisCell.cellInfo.minesTopDirection == 0)
        {
            JMSMineGridCell *neighbourCell = self.map[pos.column][pos.row - 1];
            if (neighbourCell.state != MineGridCellStateOpened)
            {
                floodMap[pos.column][pos.row - 1] = @(MIN([floodMap[pos.column][pos.row - 1] integerValue], thisValue + 1));
            }
        }
    };
    void (^checkLowerCell)(struct JMSPosition) = ^(struct JMSPosition pos)
    {
        JMSMineGridCell *thisCell = self.map[pos.column][pos.row];
        NSUInteger thisValue = [floodMap[pos.column][pos.row] integerValue];
        if (thisValue < UINT32_MAX && pos.row < self.rowCount-1 && thisCell.cellInfo.minesBottomDirection == 0)
        {
            JMSMineGridCell *neighbourCell = self.map[pos.column][pos.row + 1];
            if (neighbourCell.state != MineGridCellStateOpened)
            {
                floodMap[pos.column][pos.row + 1] = @(MIN([floodMap[pos.column][pos.row + 1] integerValue], thisValue + 1));
            }
        }
    };
    
    for (NSUInteger loopsCount = 0; loopsCount < 10; loopsCount++)
    {
    for (NSInteger col = 0; col < self.colCount; col++)
        for (NSInteger row = 0; row < self.rowCount; row++)
        {
            struct JMSPosition p;
            p.row = row;
            p.column = col;
            checkRightCell(p);
            checkLowerCell(p);
        }
    for (NSInteger col = self.colCount - 1; col >= 0; col--)
        for (NSInteger row = 0; row < self.rowCount; row++)
        {
            struct JMSPosition p;
            p.row = row;
            p.column = col;
            checkLeftCell(p);
            checkLowerCell(p);
        }
    for (NSInteger col = self.colCount - 1; col >= 0; col--)
        for (NSInteger row = self.rowCount - 1; row >= 0; row--)
        {
            struct JMSPosition p;
            p.row = row;
            p.column = col;
            checkLeftCell(p);
            checkUpperCell(p);
        }
    for (NSInteger col = 0; col <= self.colCount - 1; col++)
        for (NSInteger row = self.rowCount - 1; row >= 0; row--)
        {
            struct JMSPosition p;
            p.row = row;
            p.column = col;
            checkRightCell(p);
            checkUpperCell(p);
        }
    }
    for (NSUInteger col = 0; col < self.colCount; col++)
    {
        for (NSUInteger row = 0; row < self.rowCount; row++)
        {
            if ([floodMap[col][row] integerValue] < UINT32_MAX)
            {
                JMSMineGridCell *cellToOpen = self.map[col][row];
                if (cellToOpen.state == MineGridCellStateMarked)
                {
                    unmarkedCells++;
                }
                openedCells++;
                [cellToOpen setState:MineGridCellStateOpened];
            }
        }
    }
    
    *unmarkedCount = unmarkedCells;
    *openedCount = openedCells;
    return YES;
}

@end
