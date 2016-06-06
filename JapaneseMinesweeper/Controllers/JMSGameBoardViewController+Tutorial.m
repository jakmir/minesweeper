//
//  JMSGameBoardViewController+Tutorial.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/5/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import "JMSGameBoardViewController+Tutorial.h"
#import "JMSGameboardView.h"

@implementation JMSGameBoardViewController (Tutorial)

- (JMSGameboardView *)gameboardView
{
    if ([self.view isKindOfClass:[JMSGameboardView class]])
    {
        return (JMSGameboardView *)self.view;
    }
    return nil;
}

- (void)finishTutorial
{
    [self.gameboardView updateMenuWithFinishedTutorial:YES gameFinished:self.gameboardView.mineGridView.gameFinished];
}

- (void)addTutorialView:(UIView *)tutorialView
{
    [self.gameboardView.resultsView addSubview:tutorialView];
    [self.gameboardView.resultsView bringSubviewToFront:tutorialView];
}

- (void)highlightCellWithPosition:(JMSPosition)position
{
    [self.gameboardView.mineGridView highlightCellWithPosition:position];
}

- (void)removeHighlights
{
    [self.gameboardView.mineGridView removeHighlights];
}

@end
