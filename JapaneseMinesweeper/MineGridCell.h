//
//  MineGridCell.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MineGridView;

struct MineGridCellInfo {
    NSInteger minesLeftDirection;
    NSInteger minesRightDirection;
    NSInteger minesTopDirection;
    NSInteger minesBottomDirection;
};

typedef NS_ENUM(NSUInteger, MineGridCellState) {
    MineGridCellStateOpened,
    MineGridCellStateMarked,
    MineGridCellStateClosed,
};

@interface MineGridCell : UIView

- (instancetype) initWithFrame:(CGRect)frame;

@property (nonatomic) MineGridCellState state;
@property (nonatomic) BOOL mine;

@property (nonatomic, weak) MineGridView *mineGridView;
@property (nonatomic) struct MineGridCellInfo cellInfo;
@end
