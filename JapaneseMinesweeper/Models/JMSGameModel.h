//
//  JMSGameSessionInfo.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/14/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Structs.h"
#import "AlteredCellObserver.h"
#import "Enums.h"

@interface JMSGameModel : NSObject

@property (nonatomic, readonly) NSInteger rowCount;
@property (nonatomic, readonly) NSInteger colCount;

@property (nonatomic, getter=isLevelCreated) BOOL levelCreated;

@property (nonatomic, readonly, getter=isGameFinished) BOOL gameFinished;

@property (nonatomic) NSUInteger score;
@property (nonatomic) NSUInteger level;
@property (nonatomic, readonly) NSUInteger minesCount;

@property (nonatomic, strong) NSArray *map;

- (instancetype)initWithLevel:(NSUInteger)level map:(NSArray *)map;
- (instancetype)initWithLevel:(NSUInteger)level;

- (NSUInteger)markedCellsCount;

- (CGFloat)baseScore;

- (CGFloat)progress;
- (BOOL)isMinePresentAtPosition:(JMSPosition)position;
- (void)fillMapWithLevel:(NSUInteger)level exceptPosition:(JMSPosition)position;
- (void)evaluateMapCellInfos;
- (JMSMineGridCellState) cellState:(JMSPosition)position;
- (JMSMineGridCellNeighboursSummary) cellSummary:(JMSPosition)position;
- (CGFloat)levelModifier;
- (CGFloat)cellBasedScore;
- (CGFloat)scoreToAddFromPosition:(JMSPosition)position;
- (NSInteger)cellsLeftToOpen;
- (CGFloat)bonusFromPosition:(JMSPosition)position;
- (NSInteger)markMines;
- (BOOL)openInZeroDirectionsFromPosition:(JMSPosition)position
                           unmarkedCount:(NSUInteger *)unmarkedCount
                             openedCount:(NSUInteger *)openedCount
                     shouldOpenSafeCells:(BOOL)shouldOpenSafeCells;

- (BOOL)openCellWithPosition:(JMSPosition)position;
- (void)toggleMarkWithPosition:(JMSPosition)position;

- (void)registerObserver:(id<AlteredCellObserver>)observer;
- (void)unregisterObserver:(id<AlteredCellObserver>)observer;
- (void)unregisterAllObservers;
- (void)notifyObserversWithChanges:(NSArray *)changedCells;

@end
