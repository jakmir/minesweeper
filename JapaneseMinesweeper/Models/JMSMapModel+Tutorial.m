//
//  JMSGameModel+Tutorial.m
//  JapaneseMinesweeper
//
//  Created by Denis on 5/24/19.
//  Copyright © 2019 Jakmir. All rights reserved.
//

#import "JMSMapModel+Tutorial.h"
#import "JMSMineGridCellInfo.h"

@implementation JMSMapModel (Tutorial)

- (void)fillTutorialMapWithLevel:(NSUInteger)level {
    NSInteger rowToExclude = 4, columnToExclude = 5;
    const NSInteger cellsToFillCount = 8;
    JMSPosition cellsToFill[cellsToFillCount] =
    {
        {.row = rowToExclude, .column = 0},
        {.row = rowToExclude, .column = 2},
        {.row = rowToExclude, .column = 6},
        {.row = 2, .column = columnToExclude},
        {.row = 3, .column = columnToExclude},
        {.row = 6, .column = columnToExclude},
        {.row = 8, .column = columnToExclude},
        {.row = 9, .column = columnToExclude}
    };
    for (int mineNumber = 0; mineNumber < cellsToFillCount; mineNumber++) {
        JMSMineGridCellInfo *mineGridCell = self.map[cellsToFill[mineNumber].column][cellsToFill[mineNumber].row];
        mineGridCell.mine = YES;
    }
    
    for (int mineNumber = cellsToFillCount; mineNumber < level; mineNumber++) {
        BOOL mine;
        NSInteger r, c;
        JMSMineGridCellInfo *mineGridCell;
        do {
            r = rand() % self.rowCount;
            c = rand() % self.colCount;
            mineGridCell = self.map[c][r];
            mine = mineGridCell.mine;
        }
        while (mine || r == rowToExclude || c == columnToExclude);
        mineGridCell.mine = YES;
    }
    
    self.mapReady = YES;

    [self evaluateMapCellInfos];
}
@end
