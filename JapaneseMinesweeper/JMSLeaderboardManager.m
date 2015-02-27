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
    if (![context save:&error])
    {
        NSLog(@"Oops, couldn't save: %@", [error localizedDescription]);
    }
    else
    {
        [self cleanUpOutsideTop100];
    }
}

- (void)cleanUpOutsideTop100
{
    NSArray *recordsToCleanUp = [self highScoreListWithFetchOffset:100 fetchLimit:0];
    NSError *error;
    for (NSManagedObject *managedObject in recordsToCleanUp)
    {
        [self.managedObjectContext deleteObject:managedObject];
    }
    
    [self.managedObjectContext save:&error];
    if (error)
    {
        NSLog(@"Failed to clean up top 100");
    }
    else
    {
        NSLog(@"Top 100 was cleaned up");
    }
}

- (NSArray *)highScoreList
{
    return [self highScoreListWithFetchOffset:0 fetchLimit:0];
}

- (NSArray *)highScoreListWithFetchOffset:(NSInteger)fetchOffset fetchLimit:(NSInteger)fetchLimit;
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"JMSGameSession"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO selector:@selector(compare:)];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchOffset:fetchOffset];
    [fetchRequest setFetchLimit:fetchLimit];
    NSError *error;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error)
    {
        NSLog(@"Oops, couldn't retrieve high scores. Reason is: %@", [error localizedDescription]);
        return @[];
    }
    else
    {
        return result;
    }
}
@end
