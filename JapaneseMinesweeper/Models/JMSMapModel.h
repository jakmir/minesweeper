//
//  JMSMapModel.h
//  JapaneseMinesweeper
//
//  Created by Denis on 5/27/19.
//  Copyright © 2019 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Structs.h"
#import "AlteredCellObserver.h"
#import "Enums.h"
#import "JMSMineGridCellInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface JMSMapModel : NSObject

@property (nonatomic, strong) NSArray *map;
@property (nonatomic, getter=isMapReady) BOOL mapReady;

- (instancetype)initWithMap:(NSArray *)map;

- (NSInteger)rowCount;
- (NSInteger)colCount;
- (NSUInteger)markedCellsCount;

- (void)fillMapWithLevel:(NSUInteger)level exceptPosition:(JMSPosition)position;
- (void)evaluateMapCellInfos;

- (BOOL)isMinePresentAtPosition:(JMSPosition)position;
- (JMSMineGridCellState)cellState:(JMSPosition)position;
- (JMSMineGridCellNeighboursSummary)cellSummary:(JMSPosition)position;
- (NSArray *)markedRemainingMines;

- (CGFloat)bonusFromPosition:(JMSPosition)position;

- (NSArray *)openInZeroDirectionsFromPosition:(JMSPosition)position
                          shouldOpenSafeCells:(BOOL)shouldOpenSafeCells;

- (NSArray *)completeRemainingCells;

@end

NS_ASSUME_NONNULL_END
