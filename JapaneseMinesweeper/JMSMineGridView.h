//
//  MineGridView.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Structs.h"
#import "Enums.h"
#import "JMSMineGrid.h"

@class JMSGameSessionInfo;

@interface JMSMineGridView : UIView

- (void) fillTutorialMapWithLevel:(NSUInteger)level;
- (void) fillMapWithLevel:(NSUInteger)level exceptPosition:(struct JMSPosition)position;
- (struct JMSPosition)cellPositionWithCoordinateInside: (CGPoint)point;
- (BOOL) clickedWithCoordinate: (CGPoint)point;
- (void) longTappedWithCoordinate: (CGPoint)point;
- (NSInteger) cellsLeftToOpen;
- (CGFloat) bonus: (struct JMSPosition)position;
- (JMSMineGridCellState) cellState: (struct JMSPosition)position;
- (NSInteger) cellsCount;

- (NSArray *)exportMap;
- (void)importMap:(NSArray *)gameboardMap;
- (void)refreshCells;

- (void)finalizeGame;
- (void)resetGame;
- (NSInteger)markMines;

@property (nonatomic, readonly) BOOL gameFinished;
@property (nonatomic, readonly) JMSMineGrid *gameboard;

- (void)highlightCellWithPosition:(struct JMSPosition)position;
- (void)removeHighlights;

@end
