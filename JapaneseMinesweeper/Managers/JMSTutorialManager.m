//
//  JMSTutorialManager.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 3/21/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSTutorialManager.h"
#import "JMSGameBoardViewController.h"
#import "Enums.h"

@implementation JMSTutorialManager
{
    JMSTutorialStep _tutorialStep;
    JMSGameBoardViewController *_gameboardController;
    NSMutableArray *_allowedActionsMap;
}

- (instancetype)initWithGameboardController:(JMSGameBoardViewController *)gameboardController
{
    if (self = [super init])
    {
        _gameboardController = gameboardController;
    }
    return self;
}

- (void)moveToNextStep
{
    if (_tutorialStep < JMSTutorialStepCompleted)
    {
        _tutorialStep++;
        [self updateTutorial];
    }
}

- (void)updateTutorial
{
    
}

- (void)clearAllowedActionsMap
{
    if (!_gameboardController) return;
    if (!_allowedActionsMap)
    {
        _allowedActionsMap = [NSMutableArray array];
        for (NSUInteger col = 0; col < 10; col++)
        {
            NSMutableArray *vector = [NSMutableArray array];
            for (NSUInteger row = 0; row < 10; row++)
            {
                [vector addObject:@(JMSAllowedActionsNone)];
            }
            [_allowedActionsMap addObject:vector];
        }
    }
}

- (void)putAllowedAction:(JMSAllowedAction)allowedAction position:(struct JMSPosition)position
{
    if (position.row < 0 || position.column < 0 || position.row >= 10 || position.column >= 10) return;
    
    _allowedActionsMap[position.column][position.row] = @(allowedAction);
}

- (JMSAllowedAction)allowedActionForPosition:(struct JMSPosition)position
{
    if (position.row < 0 || position.column < 0 || position.row >= 10 || position.column >= 10) return JMSAllowedActionsNone;
    
    return [_allowedActionsMap[position.column][position.row] integerValue];
}

- (void)putAllowedActions
{
    [self clearAllowedActionsMap];
    
    switch (_tutorialStep)
    {
        case JMSTutorialStepFirstCellClick:
        {
            struct JMSPosition position = {.column = 5, .row = 4};
            [self putAllowedAction:JMSAllowedActionsClick position:position];
            break;
        }
        case JMSTutorialStepSecondCellClick:
        {
            struct JMSPosition position = {.column = 5, .row = 1};
            [self putAllowedAction:JMSAllowedActionsClick position:position];
            break;
        }
        case JMSTutorialStepPutFlags:
        {
            struct JMSPosition position1 = {.column = 5, .row = 2};
            struct JMSPosition position2 = {.column = 5, .row = 3};
            [self putAllowedAction:JMSAllowedActionsMark position:position1];
            [self putAllowedAction:JMSAllowedActionsMark position:position2];
            break;
        }
        case JMSTutorialStepThirdCellClick:
        {
            struct JMSPosition position = {.column = 5, .row = 1};
            [self putAllowedAction:JMSAllowedActionsClick position:position];
        }
        default:
            break;
    }
}

- (UIView *)prepareView
{
    if (!_gameboardController) return NULL;
    
    UIView *tutorialStepView = [[UIView alloc] initWithFrame:_gameboardController.resultsView.bounds];
    switch (_tutorialStep)
    {
        case JMSTutorialStepFirstCellClick:
        {
            UILabel *description = [[UILabel alloc] initWithFrame:tutorialStepView.frame];
            description.text = @"Tap (5;4)";
            [tutorialStepView addSubview:description];
        }
            break;
        
        default:
            break;
    }
    return tutorialStepView;
}
@end
