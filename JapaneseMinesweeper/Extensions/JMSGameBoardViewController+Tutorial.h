//
//  JMSGameBoardViewController+Tutorial.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/5/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import "JMSGameBoardViewController.h"

@interface JMSGameBoardViewController (Tutorial)

- (void)finishTutorial;
- (void)addTutorialView:(UIView *)tutorialView;
- (void)highlightCellWithPosition:(JMSPosition)position;
- (void)removeHighlights;

@end
