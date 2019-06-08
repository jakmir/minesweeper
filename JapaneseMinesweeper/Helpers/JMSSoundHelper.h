//
//  JMSSoundHelper.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/23/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JMSSoundAction)
{
    JMSSoundActionNone,
    JMSSoundActionLevelCompleted,
    JMSSoundActionGameFailed,
    JMSSoundActionCellTap,
    JMSSoundActionPutFlag,
    JMSSoundActionMenuButtonClick
};

@interface JMSSoundHelper : NSObject

+ (instancetype)shared;
- (void)playSoundWithAction:(JMSSoundAction)soundAction;
- (void)muteSound:(BOOL)mute;

@end
