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
#import "Structs.h"
#import "JMSTutorialTask.h"
#import "UIColor+ColorFromHexString.h"
#import "JMSMineGridCell.h"

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

- (NSUInteger)fieldDimension
{
    return 10;
}

- (void)moveToNextStep
{
    if (_tutorialStep < JMSTutorialStepCompleted)
    {
        _tutorialStep++;
        [self updateTutorial];
    }
    if (_tutorialStep == JMSTutorialStepCompleted)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:NO forKey:@"shouldLaunchTutorial"];
        [userDefaults synchronize];
        [_gameboardController finishTutorial];
    }
}

- (void)updateTutorial
{
    UIView *tutorialStepView = [self prepareView];
    [_gameboardController.resultsView addSubview:tutorialStepView];
    [_gameboardController.resultsView bringSubviewToFront:tutorialStepView];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    NSLog(@"%@", NSStringFromCGRect(tutorialStepView.frame));
    tutorialStepView.frame = CGRectOffset(tutorialStepView.frame, screenSize.width, 0);
    NSLog(@"%@", NSStringFromCGRect(tutorialStepView.frame));    
    [UIView animateWithDuration:1 delay:0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         if (_previousTutorialStepView)
                         {
                             _previousTutorialStepView.frame = CGRectOffset(_previousTutorialStepView.frame, -screenSize.width, 0);
                         }
                         tutorialStepView.frame = CGRectOffset(tutorialStepView.frame, -screenSize.width, 0);
                         
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
        for (NSUInteger col = 0; col < [self fieldDimension]; col++)
        {
            NSMutableArray *vector = [NSMutableArray array];
            for (NSUInteger row = 0; row < [self fieldDimension]; row++)
            {
                [vector addObject:@(JMSAllowedActionsNone)];
            }
            [_allowedActionsMap addObject:vector];
        }
    }

    for (NSUInteger col = 0; col < [self fieldDimension]; col++)
    {
        NSMutableArray *vector = _allowedActionsMap[col];
        for (NSUInteger row = 0; row < [self fieldDimension]; row++)
        {
            vector[row] = @(JMSAllowedActionsNone);
        }
    }
    
    [_gameboardController.mineGridView removeHighlights];
}

- (void)updateHighlightedCells
{
    for (NSUInteger col = 0; col < [self fieldDimension]; col++)
    {
        NSMutableArray *vector = _allowedActionsMap[col];
        for (NSUInteger row = 0; row < [self fieldDimension]; row++)
        {
            if ([vector[row] integerValue] != JMSAllowedActionsNone)
            {
                JMSPosition position = {.column = col, .row = row};
                [_gameboardController.mineGridView highlightCellWithPosition:position];
            }
        }
    }
}

- (BOOL)isAllowedWithAction:(JMSAllowedAction)action position:(JMSPosition)position
{
    return ([_allowedActionsMap[position.column][position.row] integerValue] & action ) == action;
}

- (void)putAllowedAction:(JMSAllowedAction)allowedAction position:(JMSPosition)position
{
    if (position.row < 0 || position.column < 0 || position.row >= [self fieldDimension] || position.column >= [self fieldDimension])
        return;
    
    _allowedActionsMap[position.column][position.row] = @(allowedAction);
}

- (JMSAllowedAction)allowedActionForPosition:(JMSPosition)position
{
    if (position.row < 0 || position.column < 0 || position.row >= [self fieldDimension] || position.column >= [self fieldDimension])
        return JMSAllowedActionsNone;
    
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
            JMSPosition position = {.column = 5, .row = 4};
            JMSAllowedAction action = JMSAllowedActionsClick;
            [self putAllowedAction:action position:position];
            [_tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position action:action]];
            break;
        }
        case JMSTutorialStepSecondCellClick:
        {
            JMSPosition position = {.column = 5, .row = 1};
            JMSAllowedAction action = JMSAllowedActionsClick;
            [self putAllowedAction:action position:position];
            [_tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position action:action]];            
            break;
        }
        case JMSTutorialStepPutFlags:
        {
            JMSPosition position1 = {.column = 5, .row = 2};
            JMSPosition position2 = {.column = 5, .row = 3};
            [self putAllowedAction:JMSAllowedActionsMark position:position1];
            [self putAllowedAction:JMSAllowedActionsMark position:position2];
            [_tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position1 action:JMSAllowedActionsMark]];
            [_tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position2 action:JMSAllowedActionsMark]];
            break;
        }
        case JMSTutorialStepThirdCellClick:
        {
            JMSPosition position = {.column = 5, .row = 0};
            JMSAllowedAction action = JMSAllowedActionsClick;
            [self putAllowedAction:action position:position];
            [_tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position action:action]];
            break;
        }
        case JMSTutorialStepLastCellClick:
        {
            JMSPosition position = {.column = 8, .row = 4};
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
   
    NSDictionary *attributesDescription = @{
                                                NSForegroundColorAttributeName: [UIColor whiteColor],
                                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:18]
                                            };
    NSDictionary *attributesHeader = @{
                                        NSForegroundColorAttributeName: [UIColor whiteColor],
                                        NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:32]
                                       };
    const CGFloat padding = 16;
    switch (_tutorialStep)
    {
        case JMSTutorialStepFirstCellClick:
        {
            UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          tutorialStepView.bounds.size.width,
                                                                          tutorialStepView.bounds.size.height / 2)];

            lbHeader.attributedText = [[NSAttributedString alloc] initWithString:@"Welcome to tutorial mode" attributes:attributesHeader];
            lbHeader.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:lbHeader];
            
            UILabel *lbDescription = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                               CGRectGetMidY(tutorialStepView.bounds),
                                                                               tutorialStepView.bounds.size.width,
                                                                               tutorialStepView.bounds.size.height / 2)];
            lbDescription.attributedText = [[NSAttributedString alloc] initWithString:@"Tap the highlighted cell to make your first step"
                                                                           attributes:attributesDescription];
            lbDescription.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:lbDescription];
            break;
        }
        case JMSTutorialStepSecondCellClick:
        {
            UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          tutorialStepView.bounds.size.width,
                                                                          tutorialStepView.bounds.size.height * 0.40)];
            lbHeader.attributedText = [[NSAttributedString alloc] initWithString:@"What do these numbers mean:" attributes:attributesHeader];
            lbHeader.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:lbHeader];
            
            JMSPosition position = {.column = 5, .row = 4};
            JMSMineGridCellNeighboursSummary cellSummary = [_gameboardController.mineGridView cellSummaryWithPosition:position];


            UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(padding,
                                                                             tutorialStepView.bounds.size.height * 0.40,
                                                                             tutorialStepView.bounds.size.width - padding * 2,
                                                                             tutorialStepView.bounds.size.height * 0.30)];
            description.numberOfLines = 0;
            description.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"There are %ld mines above the opened cell in its column, %ld mines - below.\nAnd %ld to the left in the row, %ld to the right (between opened cell and wall).", (long)cellSummary.minesTopDirection, (long)cellSummary.minesBottomDirection, (long)cellSummary.minesLeftDirection, (long)cellSummary.minesRightDirection] attributes:attributesDescription];
            description.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:description];
            
            UILabel *callToAction = [[UILabel alloc] initWithFrame:CGRectMake(padding,
                                                                              tutorialStepView.bounds.size.height * 0.70,
                                                                              tutorialStepView.bounds.size.width - padding * 2,
                                                                              tutorialStepView.bounds.size.height * 0.30)];
            callToAction.numberOfLines = 0;
            NSDictionary *attributesCallToAction = attributesDescription;
            NSString *actionString = @"Four cells in the section above and only two are safe. Tap highlighted cell again.";
            callToAction.attributedText = [[NSAttributedString alloc] initWithString:actionString
                                                                          attributes:attributesCallToAction];
            callToAction.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:callToAction];
            
            break;
        }
        case JMSTutorialStepPutFlags:
        {
            UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          tutorialStepView.bounds.size.width,
                                                                          tutorialStepView.bounds.size.height * 0.50)];
            lbHeader.attributedText = [[NSAttributedString alloc] initWithString:@"Drop flags to mark mines by long tap"
                                                                      attributes:attributesHeader];
            lbHeader.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:lbHeader];
            
            UILabel *lbDescription = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                               CGRectGetMidY(tutorialStepView.bounds),
                                                                               tutorialStepView.bounds.size.width,
                                                                               tutorialStepView.bounds.size.height / 2)];
            lbDescription.numberOfLines = 0;
            lbDescription.attributedText = [[NSAttributedString alloc] initWithString:@"Long tap drops flag to the specific position. Do it twice for every highlighted cell.\n\n(You can change long tap duration anytime. Available in options screen)"
                                                                           attributes:attributesDescription];
            lbDescription.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:lbDescription];
            break;
        }
        case JMSTutorialStepThirdCellClick:
        {

            UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          tutorialStepView.bounds.size.width,
                                                                          tutorialStepView.bounds.size.height * 0.40)];
            lbHeader.attributedText = [[NSAttributedString alloc] initWithString:@"Great! Let's move on" attributes:attributesHeader];
            lbHeader.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:lbHeader];
            
            UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(padding,
                                                                             tutorialStepView.bounds.size.height * 0.40,
                                                                             tutorialStepView.bounds.size.width - padding * 2,
                                                                             tutorialStepView.bounds.size.height * 0.60)];

            NSString *descriptionText = @"Highlighted cell is absolutely safe, tap to open it.\n\nLater, all cells in 'zero' directions from tapped will be opened automatically.";
            description.numberOfLines = 0;
            description.attributedText = [[NSAttributedString alloc] initWithString:descriptionText attributes:attributesDescription];
            description.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:description];
            
            break;
        }
        case JMSTutorialStepLastCellClick:
        {
            UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          tutorialStepView.bounds.size.width,
                                                                          tutorialStepView.bounds.size.height * 0.50)];
            lbHeader.attributedText = [[NSAttributedString alloc] initWithString:@"The last step" attributes:attributesHeader];
            lbHeader.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:lbHeader];
            
            UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(padding,
                                                                             tutorialStepView.bounds.size.height * 0.40,
                                                                             tutorialStepView.bounds.size.width - padding * 2,
                                                                             tutorialStepView.bounds.size.height * 0.60)];
            
            NSString *descriptionText = @"Now we deal with section right of the first opened cell.\n\nTap highlighed cell to open. Every opened cell awards you with score.\nAnd bonus score as well, depending on probability to meet a mine in that cell.";
            description.numberOfLines = 0;
            description.attributedText = [[NSAttributedString alloc] initWithString:descriptionText attributes:attributesDescription];
            description.textAlignment = NSTextAlignmentCenter;
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
            lbDescription.attributedText = [[NSAttributedString alloc] initWithString:@"Difficulty level can be changed in options section at any time."
                                                                           attributes:attributesDescription];
            lbDescription.textAlignment = NSTextAlignmentCenter;
            [tutorialStepView addSubview:lbDescription];
            
            [UIView animateWithDuration:3 delay:5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                if (tutorialStepView) tutorialStepView.alpha = 0;
            } completion:^(BOOL finished) {
                if (tutorialStepView) [tutorialStepView removeFromSuperview];
            }];
            break;
        }
        default:
            break;
    }
    return tutorialStepView;
}


- (BOOL)taskCompletedWithPosition:(JMSPosition)position
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
- (void)completeTaskWithPosition:(JMSPosition)position
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
