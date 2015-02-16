//
//  JMSGameSessionInfo.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/14/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSGameSessionInfo.h"
#import "JMSMineGridCellInfo.h"

@implementation JMSGameSessionInfo

- (NSUInteger)markedCellsCount
{
    if (!self.map) return 0;
    
    NSUInteger count = 0;
    for (NSUInteger col = 0; col < self.map.count; col++)
    {
        NSArray *vector = self.map[col];
        for (NSUInteger row = 0; row < vector.count; row++)
        {
            JMSMineGridCellInfo *mineGridCellInfo = vector[row];
            if (mineGridCellInfo.state == MineGridCellStateMarked) count++;
        }
    }
    return count;
}

@end
