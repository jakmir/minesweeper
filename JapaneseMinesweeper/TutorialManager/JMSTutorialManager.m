//
//  JMSTutorialManager.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 3/21/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSTutorialManager.h"
#import "JMSGameBoardViewController+Tutorial.h"
#import "Enums.h"
#import "Structs.h"
#import "JMSTutorialTask.h"
#import "UIColor+ColorFromHexString.h"
#import "JMSMineGridCell.h"
#import "JMSGameModel.h"

static const CGFloat kTutorialViewPadding = 16;
static const NSUInteger kFieldDimension = 10;

@interface JMSTutorialManager()

@property (nonatomic, readonly) CGSize size;
@property (nonatomic) JMSTutorialStep tutorialStep;
@property (nonatomic, weak) JMSGameBoardViewController *gameboardController;
@property (nonatomic, strong) NSMutableArray *allowedActionsMap;

@property (nonatomic, strong) UIView *previousTutorialStepView;

@property (nonatomic, strong) NSMutableArray *tasks;

@end

@implementation JMSTutorialManager

#pragma mark - Init

- (instancetype)initWithGameboardController:(JMSGameBoardViewController *)gameboardController size:(CGSize)size {
    if (self = [super init]) {
        _gameboardController = gameboardController;
        _tutorialStep = JMSTutorialStepNotStarted;
        _tasks = [NSMutableArray array];
        _size = size;
    }
    return self;
}

#pragma mark - Computable Properties

- (BOOL)shouldLaunchTutorial {
    return [[JMSSettings shared] shouldLaunchTutorial];
}

- (NSUInteger)fieldDimension {
    return kFieldDimension;
}

- (NSDictionary *)attributesDescription {
    return @{
                NSForegroundColorAttributeName: [UIColor whiteColor],
                NSFontAttributeName: [UIFont systemFontOfSize:18]
            };
}

- (NSDictionary *)attributesHeader {
    return @{
                NSForegroundColorAttributeName: [UIColor whiteColor],
                NSFontAttributeName: [UIFont systemFontOfSize:32 weight:UIFontWeightMedium]
            };
}

- (BOOL)isFinished {
    return _tutorialStep >= JMSTutorialStepCompleted;
}

- (JMSTutorialStep)currentStep {
    return _tutorialStep;
}

#pragma mark - Tutorial Navigation Actions

- (void)moveToNextStep {
    if (_tutorialStep < JMSTutorialStepCompleted) {
        _tutorialStep++;
        [self updateTutorial];
    }
    if (_tutorialStep == JMSTutorialStepCompleted) {
        [[JMSSettings shared] setShouldLaunchTutorial:NO];
        [_gameboardController finishTutorial];
    }
}

- (BOOL)isAllowedWithAction:(JMSAllowedAction)action position:(JMSPosition)position {
    NSInteger allowedActions = [self.allowedActionsMap[position.column][position.row] integerValue];
    return (allowedActions & action ) == action;
}

- (BOOL)putAllowedAction:(JMSAllowedAction)allowedAction position:(JMSPosition)position {
    if (position.row < 0 || position.column < 0 || position.row >= [self fieldDimension] || position.column >= [self fieldDimension])
        return NO;
    
    self.allowedActionsMap[position.column][position.row] = @(allowedAction);
    return YES;
}

- (JMSAllowedAction)allowedActionForPosition:(JMSPosition)position {
    if (position.row < 0 || position.column < 0 || position.row >= [self fieldDimension] || position.column >= [self fieldDimension])
        return JMSAllowedActionsNone;
    
    return [self.allowedActionsMap[position.column][position.row] integerValue];
}

- (void)putAllowedActions {
    [self clearAllowedActionsMap];
    [self clearTasks];
    
    switch (self.tutorialStep)
    {
        case JMSTutorialStepFirstCellClick:
        {
            JMSPosition position = {.column = 5, .row = 4};
            JMSAllowedAction action = JMSAllowedActionsClick;
            [self putAllowedAction:action position:position];
            [self.tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position action:action]];
            break;
        }
        case JMSTutorialStepSecondCellClick:
        {
            JMSPosition position = {.column = 5, .row = 1};
            JMSAllowedAction action = JMSAllowedActionsClick;
            [self putAllowedAction:action position:position];
            [self.tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position action:action]];
            break;
        }
        case JMSTutorialStepPutFlags:
        {
            JMSPosition position1 = {.column = 5, .row = 2};
            JMSPosition position2 = {.column = 5, .row = 3};
            [self putAllowedAction:JMSAllowedActionsMark position:position1];
            [self putAllowedAction:JMSAllowedActionsMark position:position2];
            [self.tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position1 action:JMSAllowedActionsMark]];
            [self.tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position2 action:JMSAllowedActionsMark]];
            break;
        }
        case JMSTutorialStepThirdCellClick:
        {
            JMSPosition position = {.column = 5, .row = 0};
            JMSAllowedAction action = JMSAllowedActionsClick;
            [self putAllowedAction:action position:position];
            [self.tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position action:action]];
            break;
        }
        case JMSTutorialStepLastCellClick:
        {
            JMSPosition position = {.column = 8, .row = 4};
            JMSAllowedAction action = JMSAllowedActionsClick;
            [self putAllowedAction:action position:position];
            [self.tasks addObject:[[JMSTutorialTask alloc] initWithPosition:position action:action]];
            break;
        }
        default:
            break;
    }
}


- (BOOL)taskCompletedWithPosition:(JMSPosition)position {
    __block BOOL result = NO;
    [self.tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        JMSTutorialTask *task = obj;
        if (task.position.row == position.row && task.position.column == position.column && task.isCompleted) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

- (void)completeTaskWithPosition:(JMSPosition)position {
    [self.tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        JMSTutorialTask *task = obj;
        if (task.position.row == position.row && task.position.column == position.column) {
            [task setCompleted:YES];
            *stop = YES;
        }
    }];
    
    [self checkTasks];
}

- (void)checkTasks {
    __block BOOL allCompleted = YES;
    [self.tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        JMSTutorialTask *task = obj;
        allCompleted &= task.completed;
        if (!allCompleted) {
            *stop = YES;
        }
    }];
    
    if (allCompleted) {
        [self moveToNextStep];
    }
}

#pragma mark - Tutorial UI-affecting Actions

- (void)updateTutorial {
    UIView *tutorialStepView = [self prepareView];
    [self.gameboardController addTutorialView:tutorialStepView];
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    tutorialStepView.frame = CGRectOffset(tutorialStepView.frame, screenSize.width, 0);  
    [UIView animateWithDuration:1 delay:0
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
                         if (self.previousTutorialStepView) {
                             self.previousTutorialStepView.frame = CGRectOffset(self.previousTutorialStepView.frame, -screenSize.width, 0);
                         }
                         tutorialStepView.frame = CGRectOffset(tutorialStepView.frame, -screenSize.width, 0);
                         
                     } completion:^(BOOL finished) {
                         self.previousTutorialStepView = tutorialStepView;
                         [self putAllowedActions];
                         [self updateHighlightedCells];
                     }];
}

- (void)clearTasks {
    [self.tasks removeAllObjects];
}

- (void)clearAllowedActionsMap {
    if (!self.gameboardController) {
        return;
    }
    if (!self.allowedActionsMap) {
        self.allowedActionsMap = [NSMutableArray array];
        for (NSUInteger col = 0; col < [self fieldDimension]; col++) {
            NSMutableArray *vector = [NSMutableArray array];
            for (NSUInteger row = 0; row < [self fieldDimension]; row++) {
                [vector addObject:@(JMSAllowedActionsNone)];
            }
            [self.allowedActionsMap addObject:vector];
        }
    }

    for (NSUInteger col = 0; col < [self fieldDimension]; col++) {
        NSMutableArray *vector = self.allowedActionsMap[col];
        for (NSUInteger row = 0; row < [self fieldDimension]; row++) {
            vector[row] = @(JMSAllowedActionsNone);
        }
    }
    
    [self.gameboardController removeHighlights];
}

- (void)updateHighlightedCells {
    for (NSUInteger col = 0; col < [self fieldDimension]; col++) {
        NSMutableArray *vector = self.allowedActionsMap[col];
        for (NSUInteger row = 0; row < [self fieldDimension]; row++) {
            if ([vector[row] integerValue] == JMSAllowedActionsNone) {
                continue;
            }
            JMSPosition position = {.column = col, .row = row};
            [self.gameboardController highlightCellWithPosition:position];
        }
    }
}


#pragma mark - Tutorial Explanation View generators

- (void)fillTutorialStepViewWithFirstCellView:(UIView *)tutorialStepView {
    UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  tutorialStepView.bounds.size.width,
                                                                  tutorialStepView.bounds.size.height / 2)];
    NSString *headerString = NSLocalizedString(@"Welcome to tutorial mode", nil);
    lbHeader.attributedText = [[NSAttributedString alloc] initWithString:headerString attributes:[self attributesHeader]];
    lbHeader.textAlignment = NSTextAlignmentCenter;
    [tutorialStepView addSubview:lbHeader];
    
    UILabel *lbDescription = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                       CGRectGetMidY(tutorialStepView.bounds),
                                                                       tutorialStepView.bounds.size.width,
                                                                       tutorialStepView.bounds.size.height / 2)];
    NSString *descriptionString = NSLocalizedString(@"Tap the highlighted cell to make your first step", nil);
    lbDescription.attributedText = [[NSAttributedString alloc] initWithString:descriptionString
                                                                   attributes:[self attributesDescription]];
    lbDescription.textAlignment = NSTextAlignmentCenter;
    [tutorialStepView addSubview:lbDescription];
}

- (void)fillTutorialStepViewWithSecondCellView:(UIView *)tutorialStepView {
    UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  tutorialStepView.bounds.size.width,
                                                                  tutorialStepView.bounds.size.height * 0.40)];
    NSString *headerString = NSLocalizedString(@"What do these numbers mean:", nil);
    lbHeader.attributedText = [[NSAttributedString alloc] initWithString:headerString attributes:[self attributesHeader]];
    lbHeader.textAlignment = NSTextAlignmentCenter;
    [tutorialStepView addSubview:lbHeader];
    
    JMSPosition position = {.column = 5, .row = 4};
    JMSMineGridCellNeighboursSummary cellSummary = [self.gameboardController.gameModel.mapModel cellSummary:position];
    
    
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(kTutorialViewPadding,
                                                                     tutorialStepView.bounds.size.height * 0.40,
                                                                     tutorialStepView.bounds.size.width - kTutorialViewPadding * 2,
                                                                     tutorialStepView.bounds.size.height * 0.30)];
    NSString *descriptionFormatString = NSLocalizedString(@"SecondCellDescription", nil);
    description.numberOfLines = 0;
    description.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:descriptionFormatString, (long)cellSummary.minesTopDirection, (long)cellSummary.minesBottomDirection, (long)cellSummary.minesLeftDirection, (long)cellSummary.minesRightDirection] attributes:[self attributesDescription]];
    description.textAlignment = NSTextAlignmentCenter;
    [tutorialStepView addSubview:description];
    
    UILabel *callToAction = [[UILabel alloc] initWithFrame:CGRectMake(kTutorialViewPadding,
                                                                      tutorialStepView.bounds.size.height * 0.70,
                                                                      tutorialStepView.bounds.size.width - kTutorialViewPadding * 2,
                                                                      tutorialStepView.bounds.size.height * 0.30)];
    callToAction.numberOfLines = 0;
    NSDictionary *attributesCallToAction = [self attributesDescription];
    NSString *actionString = NSLocalizedString(@"Four cells in the section above and only two are safe. Tap highlighted cell again.", nil);
    callToAction.attributedText = [[NSAttributedString alloc] initWithString:actionString
                                                                  attributes:attributesCallToAction];
    callToAction.textAlignment = NSTextAlignmentCenter;
    [tutorialStepView addSubview:callToAction];
}

- (void)fillTutorialStepViewWithPutFlagView:(UIView *)tutorialStepView {
    UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  tutorialStepView.bounds.size.width,
                                                                  tutorialStepView.bounds.size.height * 0.50)];
    lbHeader.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Drop flags to mark mines by long tap", nil)
                                                              attributes:[self attributesHeader]];
    lbHeader.textAlignment = NSTextAlignmentCenter;
    [tutorialStepView addSubview:lbHeader];
    
    UILabel *lbDescription = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                       CGRectGetMidY(tutorialStepView.bounds),
                                                                       tutorialStepView.bounds.size.width,
                                                                       tutorialStepView.bounds.size.height / 2)];
    NSString *descriptionText = NSLocalizedString(@"PutFlag1DescriptionText", nil);
    lbDescription.numberOfLines = 0;
    lbDescription.attributedText = [[NSAttributedString alloc] initWithString:descriptionText
                                                                   attributes:[self attributesDescription]];
    lbDescription.textAlignment = NSTextAlignmentCenter;
    [tutorialStepView addSubview:lbDescription];
}

- (void)fillTutorialStepViewWithThirdCellView:(UIView *)tutorialStepView {
    UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  tutorialStepView.bounds.size.width,
                                                                  tutorialStepView.bounds.size.height * 0.40)];
    lbHeader.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Great! Let's move on", nil)
                                                              attributes:[self attributesHeader]];
    lbHeader.textAlignment = NSTextAlignmentCenter;
    [tutorialStepView addSubview:lbHeader];
    
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(kTutorialViewPadding,
                                                                     tutorialStepView.bounds.size.height * 0.40,
                                                                     tutorialStepView.bounds.size.width - kTutorialViewPadding * 2,
                                                                     tutorialStepView.bounds.size.height * 0.60)];
    
    NSString *descriptionText = NSLocalizedString(@"ThirdCellDescription", nil);
    description.numberOfLines = 0;
    description.attributedText = [[NSAttributedString alloc] initWithString:descriptionText attributes:[self attributesDescription]];
    description.textAlignment = NSTextAlignmentCenter;
    [tutorialStepView addSubview:description];
}

- (void)fillTutorialStepViewWithLastCellView:(UIView *)tutorialStepView {
    UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  tutorialStepView.bounds.size.width,
                                                                  tutorialStepView.bounds.size.height * 0.50)];
    lbHeader.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"The last step", nil)
                                                              attributes:[self attributesHeader]];
    lbHeader.textAlignment = NSTextAlignmentCenter;
    [tutorialStepView addSubview:lbHeader];
    
    UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(kTutorialViewPadding,
                                                                     tutorialStepView.bounds.size.height * 0.40,
                                                                     tutorialStepView.bounds.size.width - kTutorialViewPadding * 2,
                                                                     tutorialStepView.bounds.size.height * 0.60)];
    
    NSString *descriptionText = NSLocalizedString(@"LastCellDescription", nil);
    description.numberOfLines = 0;
    description.attributedText = [[NSAttributedString alloc] initWithString:descriptionText attributes:[self attributesDescription]];
    description.textAlignment = NSTextAlignmentCenter;
    [tutorialStepView addSubview:description];
}

- (void)fillTutorialStepViewWithStepCompletedView:(UIView *)tutorialStepView {
    UILabel *lbHeader = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  tutorialStepView.bounds.size.width,
                                                                  tutorialStepView.bounds.size.height / 2)];
    NSDictionary *attributesHeader = @{
                                       NSForegroundColorAttributeName: [UIColor whiteColor],
                                       NSFontAttributeName: [UIFont systemFontOfSize:32 weight:UIFontWeightMedium]
                                       };
    lbHeader.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Tutorial completed!", nil)
                                                              attributes:attributesHeader];
    lbHeader.textAlignment = NSTextAlignmentCenter;
    [tutorialStepView addSubview:lbHeader];
    
    UILabel *lbDescription = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                       CGRectGetMidY(tutorialStepView.bounds),
                                                                       tutorialStepView.bounds.size.width,
                                                                       tutorialStepView.bounds.size.height / 2)];
    NSDictionary *attributesDescription = @{
                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                            NSFontAttributeName: [UIFont systemFontOfSize:24]
                                            };
    lbDescription.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"CompletedStepDescription", nil)
                                                                   attributes:attributesDescription];
    lbDescription.textAlignment = NSTextAlignmentCenter;
    [tutorialStepView addSubview:lbDescription];
}

- (UIView *)prepareView {
    if (!_gameboardController) {
        return nil;
    }
    CGRect frame = CGRectMake(0, 0, self.size.width, self.size.height);
    UIView *tutorialStepView = [[UIView alloc] initWithFrame:frame];
    tutorialStepView.backgroundColor = _tutorialStep % 2 ? [UIColor colorFromInteger:0xff7fceef] : [UIColor colorFromInteger:0xff90ceef];
   

    switch (_tutorialStep) {
        case JMSTutorialStepFirstCellClick:
        {
            [self fillTutorialStepViewWithFirstCellView:tutorialStepView];
            break;
        }
        case JMSTutorialStepSecondCellClick:
        {
            [self fillTutorialStepViewWithSecondCellView:tutorialStepView];
            break;
        }
        case JMSTutorialStepPutFlags:
        {
            [self fillTutorialStepViewWithPutFlagView:tutorialStepView];
            break;
        }
        case JMSTutorialStepThirdCellClick:
        {
            [self fillTutorialStepViewWithThirdCellView:tutorialStepView];
            break;
        }
        case JMSTutorialStepLastCellClick:
        {
            [self fillTutorialStepViewWithLastCellView:tutorialStepView];
            break;
        }
        case JMSTutorialStepCompleted:
        {
            [self fillTutorialStepViewWithStepCompletedView:tutorialStepView];
            
            [UIView animateWithDuration:3 delay:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                if (tutorialStepView) {
                    tutorialStepView.alpha = 0;
                }
            } completion:^(BOOL finished) {
                if (tutorialStepView) {
                    [tutorialStepView removeFromSuperview];
                }
            }];
            break;
        }
        default:
            break;
    }
    return tutorialStepView;
}

@end
