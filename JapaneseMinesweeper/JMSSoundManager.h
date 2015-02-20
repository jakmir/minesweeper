//
//  JMSSoundManager.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/20/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JMSSoundAction)
{
    JMSSoundActionNone,
    JMSSoundActionLevelCompleted,
    JMSSoundActionGameFailed,
    JMSSoundActionCellTap
};

@interface JMSSoundManager : NSObject

- (void)playSoundAction:(JMSSoundAction)soundAction;

@end
