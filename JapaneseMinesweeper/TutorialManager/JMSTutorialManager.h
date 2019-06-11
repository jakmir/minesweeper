//
//  JMSTutorialManager.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 3/21/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Structs.h"
#import "Enums.h"

@class JMSGameBoardViewController;

typedef NS_ENUM(NSUInteger, JMSTutorialStep)
{
    JMSTutorialStepNotStarted,
    JMSTutorialStepFirstCellClick,
    JMSTutorialStepSecondCellClick,
    JMSTutorialStepThirdCellClick,
    JMSTutorialStepPutFlags,
    JMSTutorialStepLastCellClick,
    JMSTutorialStepCompleted
};

@interface JMSTutorialManager : NSObject

- (instancetype)initWithGameboardController:(JMSGameBoardViewController *)gameboardController size:(CGSize)size;
- (void)moveToNextStep;
- (BOOL)isAllowedWithAction:(JMSAllowedAction)action position:(JMSPosition)position;
- (void)completeTaskWithPosition:(JMSPosition)position;
- (BOOL)taskCompletedWithPosition:(JMSPosition)position;
- (BOOL)isFinished;
- (JMSTutorialStep)currentStep;
- (BOOL)shouldLaunchTutorial;

@end
