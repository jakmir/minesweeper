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

#pragma mark - Designated Initializers

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
        [self setLevel:level];
        _mapModel = [[JMSMapModel alloc] initWithMap:map];
        _score = 0;
    }
    return self;
}

- (void)fillMapWithLevel:(NSUInteger)level exceptPosition:(JMSPosition)position {
    [self.mapModel fillMapWithLevel:level exceptPosition:position];
}

#pragma mark - Accessors

- (NSInteger)cellsLeftToOpen {
    if (![self.mapModel isMapReady]) {
        return 100 - self.minesCount;
    }
    
    NSInteger count = 0;
    for (NSArray *column in self.mapModel.map) {
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
    return [self.mapModel markedCellsCount];
}

- (CGFloat)baseScore {
    return kBaseScore;
}

- (CGFloat)levelModifier {
    return 1 + self.level / 100.0;
}

- (CGFloat)cellBasedScore {
    return self.baseScore * pow([self levelModifier], 4);
}

- (CGFloat)scoreToAddFromPosition:(JMSPosition)position {
    return [self cellBasedScore] * [self.mapModel bonusFromPosition:position];
}

#pragma mark - Mutators

- (void)setLevel:(NSUInteger)level {
    _level = level;
    _minesCount = level;
}

#pragma mark - Map Information Methods

- (BOOL)isMinePresentAtPosition:(JMSPosition)position {
    return [self.mapModel isMinePresentAtPosition:position];
}


#pragma mark - Map Interaction API Methods

- (NSInteger)markRemainingMines {
    NSArray *changedCells = [self.mapModel markedRemainingMines];
    if (changedCells.count > 0) {
        [self notifyObserversWithChanges:changedCells];
    }
    return changedCells.count;
}

- (BOOL)openInZeroDirectionsFromPosition:(JMSPosition)position
                     shouldOpenSafeCells:(BOOL)shouldOpenSafeCells {

    NSArray *changedCells = [self.mapModel openInZeroDirectionsFromPosition:position
                                                        shouldOpenSafeCells:shouldOpenSafeCells];

    CGFloat scoreToAdd = [self scoreToAddFromPosition:position] + [self cellBasedScore] * (changedCells.count - 1);
    self.score += scoreToAdd;
    
    if (self.cellsLeftToOpen > 0) {
        [self notifyWithCellAction:JMSCellActionSuccessfullyOpened];
    }
    else {
        self.score *= [self levelModifier];
        
        _gameFinished = YES;
        
        [self markRemainingMines];
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
    
    JMSMineGridCellInfo *cell = self.mapModel.map[position.column][position.row];
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
    [self completeRemainingCells];
    
    return YES;
}

- (void)completeRemainingCells {
    NSArray *changedCells = [self.mapModel completeRemainingCells];
    if (changedCells.count > 0) {
        [self notifyObserversWithChanges:changedCells];
    }
}

- (void)toggleMarkWithPosition:(JMSPosition)position {
    JMSMineGridCellState oldState = [self.mapModel cellState:position];

    if (self.gameFinished) {
        return;
    }
    
    JMSMineGridCellInfo *cell = self.mapModel.map[position.column][position.row];
    
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
    
    JMSMineGridCellState newState = [self.mapModel cellState:position];
    
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
