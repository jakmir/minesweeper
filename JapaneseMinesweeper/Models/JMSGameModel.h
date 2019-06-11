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
#import "JMSMapModel.h"

@interface JMSGameModel : NSObject

@property (nonatomic, readonly, getter=isGameFinished) BOOL gameFinished;

@property (nonatomic) NSUInteger score;
@property (nonatomic) NSUInteger level;
@property (nonatomic, readonly) NSUInteger minesCount;

@property (nonatomic, strong) JMSMapModel *mapModel;

- (instancetype)initWithLevel:(NSUInteger)level map:(NSArray *)map;
- (instancetype)initWithLevel:(NSUInteger)level;

- (void)fillMapWithLevel:(NSUInteger)level exceptPosition:(JMSPosition)position;

- (NSUInteger)markedCellsCount;

- (CGFloat)baseScore;

- (CGFloat)progress;
- (BOOL)isMinePresentAtPosition:(JMSPosition)position;

- (CGFloat)levelModifier;
- (CGFloat)cellBasedScore;
- (CGFloat)scoreToAddFromPosition:(JMSPosition)position;
- (NSInteger)cellsLeftToOpen;
- (NSInteger)markRemainingMines;

- (BOOL)openInZeroDirectionsFromPosition:(JMSPosition)position
                     shouldOpenSafeCells:(BOOL)shouldOpenSafeCells;

- (BOOL)openCellWithPosition:(JMSPosition)position;
- (void)toggleMarkWithPosition:(JMSPosition)position;

- (void)registerObserver:(id<AlteredCellObserver>)observer;
- (void)unregisterObserver:(id<AlteredCellObserver>)observer;
- (void)unregisterAllObservers;
- (void)notifyObserversWithChanges:(NSArray *)changedCells;

@end
