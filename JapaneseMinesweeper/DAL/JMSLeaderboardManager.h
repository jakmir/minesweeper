//
//  JMSLeaderboardManager.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/16/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSDataManagerBase.h"

@class JMSGameSession;

@interface JMSLeaderboardManager : JMSDataManagerBase

- (void)postGameScore:(NSUInteger)score level:(NSUInteger)level progress:(CGFloat)progress;
- (NSArray *)highScoreList;
- (NSInteger)rowsCount;

@end
