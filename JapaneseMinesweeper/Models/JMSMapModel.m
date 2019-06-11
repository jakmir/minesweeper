//
//  JMSMapModel.m
//  JapaneseMinesweeper
//
//  Created by Denis on 5/27/19.
//  Copyright © 2019 Jakmir. All rights reserved.
//

#import "JMSMapModel.h"
#import "JMSAlteredCellInfo.h"

static const double kSlightlyBigValuef = 1e10;
static const double kEpsilonf          = 1e-4;

@implementation JMSMapModel

- (instancetype)initWithMap:(NSArray *)map {
    if (self = [super init]) {
        _map = map;
        _mapReady = NO;
    }
    return self;
}

- (NSInteger)rowCount {
    NSArray *row = self.map.firstObject;
    return row ? row.count : 0;
}

- (NSInteger)colCount {
    return self.map.count;
}

#pragma mark - Map Filling Methods

- (void)fillMapWithLevel:(NSUInteger)level exceptPosition:(JMSPosition)position {
    if (self.rowCount == 0 || self.colCount == 0) {
        return;
    }
    
    for (int mineNumber = 1; mineNumber <= level; mineNumber++) {
        BOOL mine;
        NSInteger r, c;
        JMSMineGridCellInfo *mineGridCellInfo;
        do {
            r = rand() % self.rowCount;
            c = rand() % self.colCount;
            mineGridCellInfo = self.map[c][r];
            mine = mineGridCellInfo.mine;
        }
        while (mine || (r == position.row && c == position.column));
        mineGridCellInfo.mine = YES;
    }
    
    _mapReady = YES;
    [self evaluateMapCellInfos];
}

- (void)evaluateMapCellInfos {
    for (int col = 0; col < self.colCount; col++)
        for (int row = 0; row < self.rowCount; row++) {
            JMSMineGridCellInfo *cell = self.map[col][row];
            if (cell.mine) {
                continue;
            }
            NSUInteger left = 0, right = 0, up = 0, down = 0;
            for (int c = 0; c < self.colCount; c++) {
                JMSMineGridCellInfo *checkingCell = self.map[c][row];
                if (checkingCell.mine) {
                    if (c < col) {
                        left++;
                    }
                    else {
                        right++;
                    }
                }
            }
            for (int r = 0; r < self.rowCount; r++) {
                JMSMineGridCellInfo *checkingCell = self.map[col][r];
                if (checkingCell.mine) {
                    if (r < row)  {
                        up++;
                    }
                    else {
                        down++;
                    }
                }
            }
            JMSMineGridCellNeighboursSummary cellInfo = {
                .minesTopDirection = up, .minesBottomDirection = down,
                .minesLeftDirection = left, .minesRightDirection = right
            };
            
            cell.cellInfo = cellInfo;
        }
}

- (BOOL)isMinePresentAtPosition:(JMSPosition)position {
    JMSMineGridCellInfo *cell = self.map[position.column][position.row];
    return cell.mine;
}

- (JMSMineGridCellState)cellState:(JMSPosition)position {
    JMSMineGridCellInfo *cell = self.map[position.column][position.row];
    if (cell) {
        return cell.state;
    }
    return MineGridCellStateClosed;
}

- (JMSMineGridCellNeighboursSummary)cellSummary:(JMSPosition)position {
    JMSMineGridCellInfo *cell = self.map[position.column][position.row];
    if (cell) {
        return cell.cellInfo;
    }
    JMSMineGridCellNeighboursSummary summary = {
        .minesLeftDirection = 0, .minesRightDirection = 0,
        .minesTopDirection = 0, .minesBottomDirection = 0
    };
    return summary;
}

- (NSUInteger)markedCellsCount {
    if (!self.map) {
        return 0;
    }
    
    NSUInteger count = 0;
    for (NSUInteger col = 0; col < self.colCount; col++) {
        NSArray *vector = self.map[col];
        for (NSUInteger row = 0; row < vector.count; row++) {
            JMSMineGridCellInfo *mineGridCellInfo = vector[row];
            if (mineGridCellInfo.state == MineGridCellStateMarked) {
                count++;
            }
        }
    }
    return count;
}

- (NSArray *)markedRemainingMines {
    NSMutableArray *changedCells = [NSMutableArray array];
    
    for (NSUInteger col = 0; col < self.map.count; col++) {
        NSArray *vector = self.map[col];
        for (NSUInteger row = 0; row < vector.count; row++) {
            JMSMineGridCellInfo *cell = vector[row];
            if (cell.mine && cell.state != MineGridCellStateMarked) {
                [cell setState:MineGridCellStateMarked];
                
                JMSAlteredCellInfo *alteredCellInfo = [[JMSAlteredCellInfo alloc] initWithCellInfo:cell col:col row:row];
                [changedCells addObject:alteredCellInfo];
            }
        }
    }
    return [changedCells copy];
}

- (NSArray *)completeRemainingCells {
    NSMutableArray *changedCells = [NSMutableArray array];
    for (NSUInteger col = 0; col < self.colCount; col++) {
        for (NSUInteger row = 0; row < self.rowCount; row++) {
            JMSMineGridCellInfo *thisCell = self.map[col][row];
            switch (thisCell.state) {
                case MineGridCellStateMarked:
                    if (!thisCell.mine) {
                        thisCell.state = MineGridCellStateMarkedMistakenly;
                    }
                    break;
                case MineGridCellStateClosed:
                    if (thisCell.mine) {
                        thisCell.state = MineGridCellStateDisclosed;
                    }
                    break;
                default:
                    continue;
            }
            JMSAlteredCellInfo *alteredCellInfo = [[JMSAlteredCellInfo alloc] initWithCellInfo:thisCell col:col row:row];
            [changedCells addObject:alteredCellInfo];
        }
    }
    return [changedCells copy];
}

- (CGFloat)bonusFromPosition:(JMSPosition)position {
    NSInteger leftBound = position.column, rightBound = position.column;
    NSInteger topBound = position.row, bottomBound = position.row;
    
    BOOL(^isOpened)(JMSMineGridCellInfo *) = ^BOOL (JMSMineGridCellInfo *cell)
    {
        return cell.state == MineGridCellStateOpened;
    };
    
    JMSMineGridCellInfo *cell;
    do {
        leftBound--;
        cell = leftBound >= 0 ? self.map[leftBound][position.row] : nil;
    }
    while (!isOpened(cell));
    
    do {
        rightBound++;
        cell = rightBound < self.colCount ? self.map[rightBound][position.row] : nil;
    }
    while (!isOpened(cell));
    
    do {
        topBound--;
        cell = topBound >= 0 ? self.map[position.column][topBound] : nil;
    }
    while (!isOpened(cell));
    
    do {
        bottomBound++;
        cell = bottomBound < self.rowCount ? self.map[position.column][bottomBound] : nil;
    }
    while (!isOpened(cell));
    
    CGFloat a = kSlightlyBigValuef;
    CGFloat b = kSlightlyBigValuef;
    
    CGFloat bonus = 0, mines, length;
    JMSMineGridCellInfo *cell1, *cell2;
    
    BOOL leftBoundInside = leftBound >= 0 && leftBound < self.colCount;
    BOOL rightBoundInside = rightBound >= 0 && rightBound < self.colCount;
    BOOL topBoundInside = topBound >= 0 && topBound < self.rowCount;
    BOOL bottomBoundInside = bottomBound >= 0 && bottomBound < self.rowCount;
    BOOL horizontalLineWithPivot = leftBoundInside || rightBoundInside;
    BOOL verticalLinesWithPivot = topBoundInside || bottomBoundInside;
    
    if (horizontalLineWithPivot) {
        length = rightBound - leftBound - 1;
        
        if (!leftBoundInside) {
            leftBound = 0;
        }
        if (!rightBoundInside) {
            rightBound = self.colCount - 1;
        }
        
        cell1 = self.map[leftBound][position.row];
        cell2 = self.map[rightBound][position.row];
        mines = rightBoundInside
        ? cell2.cellInfo.minesLeftDirection - cell1.cellInfo.minesLeftDirection
        : cell1.cellInfo.minesRightDirection - cell2.cellInfo.minesRightDirection;
        
        if (mines > 0) {
            a = length / mines;
        }
    }
    
    if (verticalLinesWithPivot) {
        length = bottomBound - topBound - 1;
        
        if (!topBoundInside) {
            topBound = 0;
        }
        if (!bottomBoundInside) {
            bottomBound = self.rowCount - 1;
        }
        
        cell1 = self.map[position.column][topBound];
        cell2 = self.map[position.column][bottomBound];
        mines = bottomBoundInside
        ? cell2.cellInfo.minesTopDirection - cell1.cellInfo.minesTopDirection
        : cell1.cellInfo.minesBottomDirection - cell2.cellInfo.minesBottomDirection;
        
        if (mines > 0) {
            b = length / mines;
        }
    }
    
    if (horizontalLineWithPivot) {
        if (verticalLinesWithPivot) {
            bonus = 1 / (2 + a * b - a - b);
        }
        else {
            bonus = 1 / a;
        }
    }
    else {
        if (verticalLinesWithPivot) {
            bonus = 1 / b;
        }
    }
    
    return fabs(bonus) < kEpsilonf ? 0 : pow(1 + bonus, 3);
}

- (NSArray *)openInZeroDirectionsFromPosition:(JMSPosition)position
                          shouldOpenSafeCells:(BOOL)shouldOpenSafeCells {
    JMSMineGridCellInfo *cell = self.map[position.column][position.row];
    if (cell.state == MineGridCellStateOpened) {
        return @[];
    }
    NSMutableArray *floodMap = [NSMutableArray array];
    for (NSUInteger col = 0; col < self.colCount; col++) {
        NSMutableArray *floodColumn = [NSMutableArray array];
        for (NSUInteger row = 0; row < self.rowCount; row++) {
            [floodColumn addObject:@(UINT32_MAX)];
        }
        [floodMap addObject:floodColumn];
    }
    
    floodMap[position.column][position.row] = @(0);
    
    void (^checkLeftCell)(JMSPosition) = ^(JMSPosition pos) {
        JMSMineGridCellInfo *thisCell = self.map[pos.column][pos.row];
        NSUInteger thisValue = [floodMap[pos.column][pos.row] integerValue];
        if (thisValue < UINT32_MAX && pos.column > 0 && thisCell.cellInfo.minesLeftDirection == 0) {
            JMSMineGridCellInfo *neighbourCell = self.map[pos.column - 1][pos.row];
            if (neighbourCell.state != MineGridCellStateOpened) {
                floodMap[pos.column - 1][pos.row] = @(MIN([floodMap[pos.column - 1][pos.row] integerValue], thisValue + 1));
            }
        }
    };
    void (^checkRightCell)(JMSPosition) = ^(JMSPosition pos) {
        JMSMineGridCellInfo *thisCell = self.map[pos.column][pos.row];
        NSUInteger thisValue = [floodMap[pos.column][pos.row] integerValue];
        if (thisValue < UINT32_MAX && pos.column < self.colCount-1 && thisCell.cellInfo.minesRightDirection == 0) {
            JMSMineGridCellInfo *neighbourCell = self.map[pos.column + 1][pos.row];
            if (neighbourCell.state != MineGridCellStateOpened) {
                floodMap[pos.column + 1][pos.row] = @(MIN([floodMap[pos.column + 1][pos.row] integerValue], thisValue + 1));
            }
        }
    };
    void (^checkUpperCell)(JMSPosition) = ^(JMSPosition pos) {
        JMSMineGridCellInfo *thisCell = self.map[pos.column][pos.row];
        NSUInteger thisValue = [floodMap[pos.column][pos.row] integerValue];
        if (thisValue < UINT32_MAX && pos.row > 0 && thisCell.cellInfo.minesTopDirection == 0) {
            JMSMineGridCellInfo *neighbourCell = self.map[pos.column][pos.row - 1];
            if (neighbourCell.state != MineGridCellStateOpened) {
                floodMap[pos.column][pos.row - 1] = @(MIN([floodMap[pos.column][pos.row - 1] integerValue], thisValue + 1));
            }
        }
    };
    void (^checkLowerCell)(JMSPosition) = ^(JMSPosition pos) {
        JMSMineGridCellInfo *thisCell = self.map[pos.column][pos.row];
        NSUInteger thisValue = [floodMap[pos.column][pos.row] integerValue];
        if (thisValue < UINT32_MAX && pos.row < self.rowCount-1 && thisCell.cellInfo.minesBottomDirection == 0) {
            JMSMineGridCellInfo *neighbourCell = self.map[pos.column][pos.row + 1];
            if (neighbourCell.state != MineGridCellStateOpened) {
                floodMap[pos.column][pos.row + 1] = @(MIN([floodMap[pos.column][pos.row + 1] integerValue], thisValue + 1));
            }
        }
    };
    
    if (shouldOpenSafeCells) {
        for (NSUInteger loopsCount = 0; loopsCount < 10; loopsCount++) {
            for (NSInteger col = 0; col < self.colCount; col++) {
                for (NSInteger row = 0; row < self.rowCount; row++) {
                    JMSPosition p;
                    p.row = row;
                    p.column = col;
                    checkRightCell(p);
                    checkLowerCell(p);
                }
            }
            for (NSInteger col = self.colCount - 1; col >= 0; col--) {
                for (NSInteger row = 0; row < self.rowCount; row++) {
                    JMSPosition p;
                    p.row = row;
                    p.column = col;
                    checkLeftCell(p);
                    checkLowerCell(p);
                }
            }
            for (NSInteger col = self.colCount - 1; col >= 0; col--) {
                for (NSInteger row = self.rowCount - 1; row >= 0; row--) {
                    JMSPosition p;
                    p.row = row;
                    p.column = col;
                    checkLeftCell(p);
                    checkUpperCell(p);
                }
            }
            for (NSInteger col = 0; col <= self.colCount - 1; col++) {
                for (NSInteger row = self.rowCount - 1; row >= 0; row--) {
                    JMSPosition p;
                    p.row = row;
                    p.column = col;
                    checkRightCell(p);
                    checkUpperCell(p);
                }
            }
        }
    }
    
    NSMutableArray *changedCells = [NSMutableArray array];
    
    for (NSUInteger col = 0; col < self.colCount; col++) {
        for (NSUInteger row = 0; row < self.rowCount; row++) {
            if ([floodMap[col][row] integerValue] < UINT32_MAX) {
                JMSMineGridCellInfo *cellToOpen = self.map[col][row];
                [cellToOpen setState:MineGridCellStateOpened];
                
                JMSAlteredCellInfo *alteredCellInfo = [[JMSAlteredCellInfo alloc] initWithCellInfo:cellToOpen col:col row:row];
                [changedCells addObject:alteredCellInfo];
            }
        }
    }
    
    return [changedCells copy];
}

@end
