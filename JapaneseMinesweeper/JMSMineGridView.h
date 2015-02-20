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

@class JMSGameSessionInfo;

@interface JMSMineGridView : UIView

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

@property (nonatomic, readonly) BOOL gameFinished;

@end
