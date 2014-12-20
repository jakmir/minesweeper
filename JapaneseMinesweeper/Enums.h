//
//  Enums.h
//  JapaneseMinesweeper
//
//  Created by Denys Melnyk on 10/3/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//


#ifndef JapaneseMinesweeper_Enums_h
#define JapaneseMinesweeper_Enums_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MineGridCellState) {
    MineGridCellStateOpened,
    MineGridCellStateMarked,
    MineGridCellStateClosed,
};

typedef NS_ENUM(NSUInteger, JMSGameDifficulty) {
    JMSGameDifficultyUndefined,
    JMSGameDifficultyEasy,
    JMSGameDifficultyMedium,
    JMSGameDifficultyHard,
};

#endif
