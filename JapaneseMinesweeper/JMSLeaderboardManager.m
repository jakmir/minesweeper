//
//  JMSLeaderboardManager.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/16/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSLeaderboardManager.h"
#import "JMSGameSession.h"

@implementation JMSLeaderboardManager

- (void)postGameScore:(NSUInteger)score level:(NSUInteger)level progress:(CGFloat)progress
{
    NSManagedObjectContext *context = [self managedObjectContext];
    JMSGameSession *gameSession = [NSEntityDescription insertNewObjectForEntityForName:@"JMSGameSession"
                                                                inManagedObjectContext:context];
    gameSession.score = @(score);
    gameSession.level = @(level);
    gameSession.progress = @(progress);
    gameSession.postedAt = [NSDate date];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Oops, couldn't save: %@", [error localizedDescription]);
    }
}

- (NSArray *)highScoreList
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JMSGameSession"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *unsortedResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error)
    {
        NSLog(@"Oops, couldn't retrieve high scores. Reason is: %@", [error localizedDescription]);
        return @[];
    }
    else
    {
        return [unsortedResult sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            JMSGameSession *gameSessionLeft = obj1;
            JMSGameSession *gameSessionRight = obj2;
            if (gameSessionLeft.score.integerValue < gameSessionRight.score.integerValue)
            {
                return NSOrderedDescending;
            }
            else
            {
                if (gameSessionLeft.score.integerValue > gameSessionRight.score.integerValue)
                    return NSOrderedAscending;
            }
            return NSOrderedSame;
                
        }];
    }
}
@end
