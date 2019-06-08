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

- (void)finishTutorial {
    [self.gameboardView updateMenuWithFinishedTutorial:YES gameFinished:self.gameModel.isGameFinished];
}

- (void)addTutorialView:(UIView *)tutorialView {
    [self.gameboardView.resultsView addSubview:tutorialView];
    [self.gameboardView.resultsView bringSubviewToFront:tutorialView];
}

- (void)highlightCellWithPosition:(JMSPosition)position {
    [self.gameboardView.mineGridView highlightCellWithPosition:position];
}

- (void)removeHighlights {
    [self.gameboardView.mineGridView removeHighlights];
}

@end
