//
//  JMSTutorialManager.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 3/21/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JMSGameBoardViewController;

typedef NS_ENUM(NSUInteger, JMSTutorialStep)
{
    JMSTutorialStepFirstCellClick,
    JMSTutorialStepSecondCellClick,
    JMSTutorialStepPutFlags,
    JMSTutorialStepThirdCellClick,
    JMSTutorialStepLastCellClick,
    JMSTutorialStepCompleted
};

@interface JMSTutorialManager : NSObject

- (instancetype)initWithGameboardController:(JMSGameBoardViewController *)gameboardController;



@end
