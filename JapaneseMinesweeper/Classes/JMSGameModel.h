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

@property (nonatomic, readonly, getter=isLevelCreated) BOOL levelCreated;
@property (nonatomic) BOOL gameFinished;
@property (nonatomic) NSUInteger score;
@property (nonatomic) NSUInteger level;
@property (nonatomic, readonly) NSUInteger minesCount;

@property (nonatomic, strong) NSArray *map;

- (NSUInteger)markedCellsCount;

- (CGFloat)baseScore;

- (CGFloat)progress;
- (BOOL)mineAtPosition:(JMSPosition)position;
- (void)fillTutorialMapWithLevel:(NSUInteger)level;
- (void)fillMapWithLevel:(NSUInteger)level exceptPosition:(JMSPosition)position;
- (JMSMineGridCellState) cellState:(JMSPosition)position;
- (JMSMineGridCellNeighboursSummary) cellSummary:(JMSPosition)position;
- (CGFloat)levelModifier;
- (CGFloat)cellBasedScore;
- (CGFloat)scoreToAddFromPosition:(JMSPosition)position;
- (NSInteger)cellsLeftToOpen;
- (CGFloat)bonus:(JMSPosition)position;
- (NSInteger)markMines;
- (BOOL)openInZeroDirectionsFromPosition:(JMSPosition)position
                           unmarkedCount:(NSUInteger *)unmarkedCount
                             openedCount:(NSUInteger *)openedCount
                     shouldOpenSafeCells:(BOOL)shouldOpenSafeCells;

- (BOOL)singleTappedWithPosition:(JMSPosition)position;
- (void)longTappedWithPosition:(JMSPosition)position;

- (void)registerObserver:(id<AlteredCellObserver>)observer;
- (void)unregisterObserver:(id<AlteredCellObserver>)observer;
- (void)unregisterAllObservers;
- (void)notifyObserversWithChanges:(NSArray *)changedCells;
@end
