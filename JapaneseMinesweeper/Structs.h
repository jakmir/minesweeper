//
//  Structs.h
//  JapaneseMinesweeper
//
//  Created by Denys Melnyk on 10/3/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#ifndef JapaneseMinesweeper_Structs_h
#define JapaneseMinesweeper_Structs_h

#import <UIKit/UIKit.h>

struct JMSPosition
{
    NSInteger row;
    NSInteger column;
};

struct JMSMineGridCellNeighboursSummary {
    NSInteger minesLeftDirection;
    NSInteger minesRightDirection;
    NSInteger minesTopDirection;
    NSInteger minesBottomDirection;
};

#endif
