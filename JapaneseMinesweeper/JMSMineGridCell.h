//
//  MineGridCell.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enums.h"
#import "Structs.h"

@class JMSMineGridView, JMSMineGridCellInfo;

@interface JMSMineGridCell : UIView

- (instancetype) initWithFrame:(CGRect)frame;

@property (nonatomic) JMSMineGridCellState state;
@property (nonatomic) BOOL mine;

@property (nonatomic, weak) JMSMineGridView *mineGridView;
@property (nonatomic) struct JMSMineGridCellNeighboursSummary cellInfo;

- (JMSMineGridCellInfo *)exportCell;
- (void)import:(JMSMineGridCellInfo *)mineGridCellInfo;

@end
