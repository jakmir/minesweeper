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
#import "JMSAlteredCellInfo.h"

@class JMSGameModel;

@interface JMSMineGridView : UIView

@property (nonatomic, strong) NSArray *map;

- (JMSPosition)cellPositionWithCoordinateInside: (CGPoint)point;

- (NSArray *)exportMap;
- (void)importMap:(NSArray *)gameboardMap;
- (void)refreshCells;

- (void)finalizeGame;
- (void)resetGame;

- (void)updateCellWithAlteredCellModel:(JMSAlteredCellInfo *)alteredCellModel;

@property (nonatomic, readonly) BOOL gameFinished;

- (void)highlightCellWithPosition:(JMSPosition)position;
- (void)removeHighlights;

@end
