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
#import "JMSTutorialTask.h"
#import "UIColor+ColorFromHexString.h"
@implementation JMSTutorialManager
{
    JMSTutorialStep _tutorialStep;
    JMSGameBoardViewController *_gameboardController;
    NSMutableArray *_allowedActionsMap;
    
    UIView *_previousTutorialStepView;
    NSMutableArray *_tasks;
}

- (instancetype)initWithGameboardController:(JMSGameBoardViewController *)gameboardController
{
    if (self = [super init])
    {
        _gameboardController = gameboardController;
        _tutorialStep = JMSTutorialStepNotStarted;
        _tasks = [NSMutableArray array];
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
    UIView *tutorialStepView = [self prepareView];
    [_gameboardController.resultsView addSubview:tutorialStepView];
    [_gameboardController.resultsView bringSubviewToFront:tutorialStepView];
    
    NSLog(@"%@", NSStringFromCGRect(tutorialStepView.frame));
    tutorialStepView.frame = CGRectOffset(tutorialStepView.frame, 768, 0);
    NSLog(@"%@", NSStringFromCGRect(tutorialStepView.frame));    
    [UIView animateWithDuration:1 delay:0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         if (_previousTutorialStepView)
                         {
                             _previousTutorialStepView.frame = CGRectOffset(_previousTutorialStepView.frame, -768, 0);
                         }
                         tutorialStepView.frame = CGRectOffset(tutorialStepView.frame, -768, 0);
                         
                     } completion:^(BOOL finished) {
                         _previousTutorialStepView = tutorialStepView;
                         [self putAllowedActions];
                         [self updateHighlightedCells];
                     }];
}

- (void)clearTasks
{
    [_tasks removeAllObjects];
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

    for (NSUInteger col = 0; col < 10; col++)
    {
        NSMutableArray *vector = _allowedActionsMap[col];
        for (NSUInteger row = 0; row < 10; row++)
        {
            vector[row] = @(JMSAllowedActionsNone);
        }
    }
    
    [_gameboardController.mineGridView removeHighlights];
}

- (void)updateHighlightedCells
{
    for (NSUInteger col = 0; col < 10; col++)
    {
        NSMutableArray *vector = _allowedActionsMap[col];
        for (NSUInteger row = 0; row < 10; row++)
        {
            if ([vector[row] integerValue] != JMSAllowedActionsNone)
            {
                struct JMSPosition position = {.column = col, .row = row};
                [_gameboardController.mineGridView highlightCellWithPosition:position];
            }
        }
    }
}

- (BOOL)isAllowedWithAction:(JMSAllowedAction)action position:(struct JMSPosition)position
{
    return ([_allowedActionsMap[position.column][position.row] integerValue] & action ) == action;
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
    [self clearTasks];
    
    switch (_tutorialStep)
    {
        case JMSTutorialStepFirstCellClick:
        {
            struct JMSPosition position = {.column = 5, .row = 4};
            JMSAllowedAction action = JMSAllowedActionsClick;
            [self putAllowedAction:action position:position];
            [_tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position action:action]];
            break;
        }
        case JMSTutorialStepSecondCellClick:
        {
            struct JMSPosition position = {.column = 5, .row = 1};
            JMSAllowedAction action = JMSAllowedActionsClick;
            [self putAllowedAction:action position:position];
            [_tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position action:action]];            
            break;
        }
        case JMSTutorialStepPutFlags:
        {
            struct JMSPosition position1 = {.column = 5, .row = 2};
            struct JMSPosition position2 = {.column = 5, .row = 3};
            [self putAllowedAction:JMSAllowedActionsMark position:position1];
            [self putAllowedAction:JMSAllowedActionsMark position:position2];
            [_tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position1 action:JMSAllowedActionsMark]];
            [_tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position2 action:JMSAllowedActionsMark]];
            break;
        }
        case JMSTutorialStepThirdCellClick:
        {
            struct JMSPosition position = {.column = 5, .row = 0};
            JMSAllowedAction action = JMSAllowedActionsClick;
            [self putAllowedAction:action position:position];
            [_tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position action:action]];
            break;
        }
        case JMSTutorialStepLastCellClick:
        {
            struct JMSPosition position = {.column = 8, .row = 4};
            JMSAllowedAction action = JMSAllowedActionsClick;
            [self putAllowedAction:action position:position];
            [_tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position action:action]];
            break;
        }
        default:
            break;
    }
}

- (UIView *)prepareView
{
    if (!_gameboardController) return NULL;
    
    CGRect frame = CGRectInset(_gameboardController.resultsView.bounds, 0, 0);
    UIView *tutorialStepView = [[UIView alloc] initWithFrame:frame];
    tutorialStepView.backgroundColor = _tutorialStep % 2 ? [UIColor colorFromInteger:0xff7fceef] : [UIColor colorFromInteger:0xff90ceef];
   
    switch (_tutorialStep)
    {
        case JMSTutorialStepFirstCellClick:
        {
            UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          tutorialStepView.bounds.size.width,
                                                                          tutorialStepView.bounds.size.height / 2)];
            NSDictionary *attributesHeader = @{
                                               NSForegroundColorAttributeName: [UIColor whiteColor],
                                               NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:32]
                                               };
            lbHeader.attributedText = [[NSAttributedString alloc] initWithString:@"Welcome to tutorial mode" attributes:attributesHeader];
            lbHeader.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:lbHeader];
            
            UILabel *lbDescription = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                               CGRectGetMidY(tutorialStepView.bounds),
                                                                               tutorialStepView.bounds.size.width,
                                                                               tutorialStepView.bounds.size.height / 2)];
            NSDictionary *attributesDescription = @{
                                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                                    NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:24]
                                               };
            lbDescription.attributedText = [[NSAttributedString alloc] initWithString:@"Tap the highlighted cell to make your first step"
                                                                           attributes:attributesDescription];
            lbDescription.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:lbDescription];
            break;
        }
        case JMSTutorialStepSecondCellClick:
        {
            UILabel *description = [[UILabel alloc] initWithFrame:tutorialStepView.bounds];
            description.text = @"Great. Tap highlighted cell again";
            [tutorialStepView addSubview:description];
        
            break;
        }
        case JMSTutorialStepPutFlags:
        {
            UILabel *description = [[UILabel alloc] initWithFrame:tutorialStepView.bounds];
            description.text = @"Now put 2 flags.";
            [tutorialStepView addSubview:description];
            
            break;
        }
        case JMSTutorialStepThirdCellClick:
        {
            UILabel *description = [[UILabel alloc] initWithFrame:tutorialStepView.bounds];
            description.text = @"You did it. Tap highlighted cell again";
            [tutorialStepView addSubview:description];
            
            break;
        }
        case JMSTutorialStepLastCellClick:
        {
            UILabel *description = [[UILabel alloc] initWithFrame:tutorialStepView.bounds];
            description.text = @"Now click the last cell";
            [tutorialStepView addSubview:description];
            
            break;
        }
        case JMSTutorialStepCompleted:
        {
            UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          tutorialStepView.bounds.size.width,
                                                                          tutorialStepView.bounds.size.height / 2)];
            NSDictionary *attributesHeader = @{
                                               NSForegroundColorAttributeName: [UIColor whiteColor],
                                               NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:32]
                                               };
            lbHeader.attributedText = [[NSAttributedString alloc] initWithString:@"Tutorial completed!" attributes:attributesHeader];
            lbHeader.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:lbHeader];
            
            UILabel *lbDescription = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                               CGRectGetMidY(tutorialStepView.bounds),
                                                                               tutorialStepView.bounds.size.width,
                                                                               tutorialStepView.bounds.size.height / 2)];
            NSDictionary *attributesDescription = @{
                                                    NSForegroundColorAttributeName: [UIColor whiteColor],
                                                    NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:24]
                                                    };
            lbDescription.attributedText = [[NSAttributedString alloc] initWithString:@"Now you are ready to play"
                                                                           attributes:attributesDescription];
            lbDescription.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:lbDescription];
            
            break;
        }
        default:
            break;
    }
    return tutorialStepView;
}

- (BOOL)taskCompletedWithPosition:(struct JMSPosition)position
{
    __block BOOL result = NO;
    [_tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        JMSTutorialTask *task = obj;
        if (task.position.row == position.row && task.position.column == position.column && task.done)
        {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}
- (void)completeTaskWithPosition:(struct JMSPosition)position
{
    [_tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        JMSTutorialTask *task = obj;
        if (task.position.row == position.row && task.position.column == position.column)
        {
            [task setDone:YES];
            *stop = YES;
        }
    }];
    
    [self checkTasks];
}

- (void)checkTasks
{
    __block BOOL allDone = YES;
    [_tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        JMSTutorialTask *task = obj;
        allDone &= task.done;
        if (!allDone) *stop = YES;
    }];
    
    if (allDone)
    {
        [self moveToNextStep];
    }
}

- (BOOL)isFinished
{
    return _tutorialStep >= JMSTutorialStepCompleted;
}

- (JMSTutorialStep)currentStep
{
    return _tutorialStep;
}
@end
