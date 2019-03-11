//
//  JMSGameSessionInfo.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/14/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSGameModel.h"
#import "JMSMineGridCellInfo.h"
#import "JMSAlteredCellInfo.h"

static const double kSlightlyBigValuef = 1e10;
static const double kEpsilonf          = 1e-4;
static const double kBaseScore         = 175;

typedef NS_ENUM(NSUInteger, JMSCellAction) {
    JMSCellActionUndefined,
    JMSCellActionFlagAdded,
    JMSCellActionFlagRemoved,
    JMSCellActionRanIntoMine,
    JMSCellActionSuccessfullyOpened
};

@interface JMSGameModel()

@property (nonatomic, strong) NSMutableArray *observerCollection;

@end


@implementation JMSGameModel

- (instancetype)init {
    return [self initWithLevel:0];
}

#pragma mark - Designed Initializers

- (instancetype)initWithLevel:(NSUInteger)level {
    NSUInteger count = 10;
    NSMutableArray *map = [NSMutableArray array];
    for (NSUInteger column = 0; column < count; column++) {
        NSMutableArray *vector = [NSMutableArray array];
        for (NSUInteger row = 0; row < count; row++) {
            JMSMineGridCellInfo *cellInfo = [[JMSMineGridCellInfo alloc] init];
            cellInfo.mine = NO;
            cellInfo.state = MineGridCellStateClosed;
            [vector addObject:cellInfo];
        }
        [map addObject:vector];
    }
    return [self initWithLevel:level map:map];
}

- (instancetype)initWithLevel:(NSUInteger)level map:(NSArray *)map {
    if (self = [super init]) {
        _observerCollection = [NSMutableArray array];
        _gameFinished = NO;
        _levelCreated = NO;
        [self setLevel:level];
        _map = map;
        _score = 0;
    }
    return self;
}

#pragma mark - Accessors

- (NSInteger)cellsLeftToOpen {
    if (![self isLevelCreated]) {
        return 100 - self.minesCount;
    }
    
    NSInteger count = 0;
    for (NSArray *column in self.map) {
        for (JMSMineGridCellInfo *cell in column) {
            if (!cell.mine && cell.state != MineGridCellStateOpened) {
                count++;
            }
        }
    }
    return count;
}

- (CGFloat)progress {
    if (self.level < 100) {
        return 100.0 * (100 - self.level - self.cellsLeftToOpen) / (100 - self.level);
    }
    return 0.0;
}

- (NSUInteger)markedCellsCount {
    if (!self.map) {
        return 0;
    }
    
    NSUInteger count = 0;
    for (NSUInteger col = 0; col < self.map.count; col++) {
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

- (CGFloat)baseScore {
    return kBaseScore;
}

- (NSInteger)rowCount {
    NSArray *row = self.map.firstObject;
    return row ? row.count : 0;
}

- (NSInteger)colCount {
    return self.map.count;
}

- (CGFloat)levelModifier {
    return 1 + self.level / 100.0;
}

- (CGFloat)cellBasedScore {
    return self.baseScore * pow([self levelModifier], 4);
}

- (CGFloat)scoreToAddFromPosition:(JMSPosition)position {
    return [self cellBasedScore] * pow(1 + [self bonusFromPosition:position], 3);
}

#pragma mark - Mutators

- (void)setLevel:(NSUInteger)level {
    _level = level;
    _minesCount = level;
}

#pragma mark - Map Information Methods

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
    
    _levelCreated = YES;
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

- (CGFloat)bonusFromPosition:(JMSPosition)position {
    NSInteger leftBound = position.column, rightBound = position.column;
    NSInteger topBound = position.row, bottomBound = position.row;
    
    BOOL(^isOpened)(JMSMineGridCellInfo *) = ^BOOL (JMSMineGridCellInfo *cell)
    {
        return cell.state == MineGridCellStateOpened;
    };
    
    BOOL (^xinsideGameboard)(NSInteger) = ^BOOL(NSInteger coordinate)
    {
        return coordinate >= 0 && coordinate < self.colCount;
    };
    
    BOOL (^yinsideGameboard)(NSInteger) = ^BOOL(NSInteger coordinate)
    {
        return coordinate >= 0 && coordinate < self.rowCount;
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
    
    NSLog(@"horizontal: %ld <-> %ld", (long)leftBound, (long)rightBound);
    NSLog(@"vertical  : %ld <-> %ld", (long)topBound, (long)bottomBound);
    
    CGFloat a = kSlightlyBigValuef;
    CGFloat b = kSlightlyBigValuef;
    
    CGFloat bonus = 0, mines, length;
    JMSMineGridCellInfo *cell1, *cell2;
    
    BOOL leftBoundInside = xinsideGameboard(leftBound);
    BOOL rightBoundInside = xinsideGameboard(rightBound);
    BOOL topBoundInside = yinsideGameboard(topBound);
    BOOL bottomBoundInside = yinsideGameboard(bottomBound);
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
    
    return fabs(bonus) < kEpsilonf ? 0 : bonus;
}

#pragma mark - Map Interaction API Methods

- (NSInteger)markMines {
    NSInteger markedCellsCount = 0;
    NSMutableArray *changedCells = [NSMutableArray array];
    
    for (NSUInteger col = 0; col < self.map.count; col++) {
        NSArray *vector = self.map[col];
        for (NSUInteger row = 0; row < vector.count; row++) {
            JMSMineGridCellInfo *cell = vector[row];
            if (cell.mine && cell.state != MineGridCellStateMarked) {
                [cell setState:MineGridCellStateMarked];
                
                JMSAlteredCellInfo *alteredCellInfo = [[JMSAlteredCellInfo alloc] initWithCellInfo:cell col:col row:row];
                [changedCells addObject:alteredCellInfo];
                markedCellsCount++;
            }
        }
    }
    if (changedCells.count > 0) {
        [self notifyObserversWithChanges:changedCells];
    }
    return markedCellsCount;
}

- (BOOL)openInZeroDirectionsFromPosition:(JMSPosition)position
                           unmarkedCount:(NSUInteger *)unmarkedCount
                             openedCount:(NSUInteger *)openedCount
                     shouldOpenSafeCells:(BOOL)shouldOpenSafeCells {
    NSUInteger unmarkedCells = 0;
    NSUInteger openedCells = 0;
    
    JMSMineGridCellInfo *cell = self.map[position.column][position.row];
    if (cell.state == MineGridCellStateOpened) {
        *unmarkedCount = 0;
        *openedCount = 0;
        return NO;
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
                if (cellToOpen.state == MineGridCellStateMarked) {
                    unmarkedCells++;
                }
                openedCells++;
                [cellToOpen setState:MineGridCellStateOpened];
                
                JMSAlteredCellInfo *alteredCellInfo = [[JMSAlteredCellInfo alloc] initWithCellInfo:cellToOpen col:col row:row];
                [changedCells addObject:alteredCellInfo];
            }
        }
    }
    
    self.score += [self scoreToAddFromPosition:position];
    self.score += [self cellBasedScore] * (openedCells - 1);
   
    if (self.cellsLeftToOpen > 0) {
        [self notifyWithCellAction:JMSCellActionSuccessfullyOpened];
    }
    else {
        self.score *= [self levelModifier];
        [self markMines];
        [self notifyWithLevelCompletion];
    }
    
    if (changedCells.count > 0) {
        [self notifyObserversWithChanges:changedCells];
    }
    return YES;
}

- (BOOL)openCellWithPosition:(JMSPosition)position {
    if (self.gameFinished) {
        return NO;
    }
    
    JMSMineGridCellInfo *cell = self.map[position.column][position.row];
    if (!cell) {
        return NO;
    }
    
    [cell setState:MineGridCellStateOpened];
    JMSAlteredCellInfo *alteredCellInfo = [[JMSAlteredCellInfo alloc] initWithCellInfo:cell
                                                                                   col:position.column
                                                                                   row:position.row];
        
    [self notifyObserversWithChanges:@[alteredCellInfo]];

    if (!cell.mine) {
        [self notifyWithCellAction:JMSCellActionSuccessfullyOpened];
        return NO;
    }
    
    _gameFinished = YES;
    
    [self notifyWithCellAction:JMSCellActionRanIntoMine];
    
    NSMutableArray *changedCells = [NSMutableArray array];
    for (NSUInteger col = 0; col < self.colCount; col++) {
        for (NSUInteger row = 0; row < self.rowCount; row++) {
            JMSMineGridCellInfo *thisCell = self.map[col][row];
            if (thisCell.mine || (thisCell.state == MineGridCellStateMarked && !thisCell.mine)) {
                JMSAlteredCellInfo *alteredCellInfo = [[JMSAlteredCellInfo alloc] initWithCellInfo:thisCell col:col row:row];
                [changedCells addObject:alteredCellInfo];
            }
        }
    }
    if (changedCells.count > 0) {
        [self notifyObserversWithChanges:changedCells];
    }
    return YES;
}

- (void)toggleMarkWithPosition:(JMSPosition)position {
    JMSMineGridCellState oldState = [self cellState:position];

    if (self.gameFinished) {
        return;
    }
    
    JMSMineGridCellInfo *cell = self.map[position.column][position.row];
    
    if (cell) {
        JMSAlteredCellInfo *alteredCellInfo = [[JMSAlteredCellInfo alloc] initWithCellInfo:cell
                                                                                       col:position.column
                                                                                       row:position.row];
        switch (cell.state) {
            case MineGridCellStateMarked:
                [cell setState:MineGridCellStateClosed];
                [self notifyObserversWithChanges:@[alteredCellInfo]];
                break;
            case MineGridCellStateClosed:
                [cell setState:MineGridCellStateMarked];
                [self notifyObserversWithChanges:@[alteredCellInfo]];
                break;
            default:
                break;
        }
    }
    
    JMSMineGridCellState newState = [self cellState:position];
    
    if (oldState == MineGridCellStateMarked && newState == MineGridCellStateClosed) {
        [self notifyWithCellAction:JMSCellActionFlagAdded];
    }
    if (oldState == MineGridCellStateClosed && newState == MineGridCellStateMarked) {
        [self notifyWithCellAction:JMSCellActionFlagRemoved];
    }

}
#pragma mark - observer methods

- (void)registerObserver:(id<AlteredCellObserver>)observer {
    [self.observerCollection addObject:observer];
}

- (void)unregisterObserver:(id<AlteredCellObserver>)observer {
    [self.observerCollection removeObject:observer];
}

- (void)unregisterAllObservers {
    [self.observerCollection removeAllObjects];
}

- (void)notifyObserversWithChanges:(NSArray *)changedCells {
    for (id<AlteredCellObserver> observer in self.observerCollection) {
        [observer cellsChanged:changedCells];
    }
}

- (void)notifyWithCellAction:(JMSCellAction)action {
    for (id<AlteredCellObserver> observer in self.observerCollection) {
        switch (action) {
            case JMSCellActionFlagAdded:
                [observer flagAdded];
                break;
            case JMSCellActionFlagRemoved:
                [observer flagRemoved];
                break;
            case JMSCellActionSuccessfullyOpened:
                [observer cellSuccessfullyOpened];
                break;
            case JMSCellActionRanIntoMine:
                [observer ranIntoMine];
                break;
            default:
                break;
        }
    }
}

- (void)notifyWithLevelCompletion {
    for (id<AlteredCellObserver> observer in self.observerCollection) {
        [observer levelCompleted];
    }
}

@end
