//
//  JMSMineGrid.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/21/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Structs.h"
#import "Enums.h"

@interface JMSMineGrid : NSObject

@property (nonatomic, strong) NSArray *map;

- (NSInteger) rowCount;
- (NSInteger) colCount;
- (NSInteger) cellsLeftToOpen;

- (void) fillTutorialMapWithLevel:(NSUInteger)level;
- (void) fillMapWithLevel:(NSUInteger)level exceptPosition:(JMSPosition)position;
- (void) evaluateMapCellInfos;
- (CGFloat)bonus:(JMSPosition)position;
- (BOOL) mineAtPosition:(JMSPosition)position;
- (JMSMineGridCellState) cellState:(JMSPosition)position;
- (JMSMineGridCellNeighboursSummary) cellSummary:(JMSPosition)position;
- (NSInteger)markMines;
- (BOOL)openInZeroDirectionsFromPosition:(JMSPosition)position
                           unmarkedCount:(NSUInteger *)unmarkedCount
                             openedCount:(NSUInteger *)openedCount
                     shouldOpenSafeCells:(BOOL)shouldOpenSafeCells;

@end
