//
//  JMSSoundHelper.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/23/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSSoundHelper.h"
#import <AVFoundation/AVFoundation.h>

@implementation JMSSoundHelper
{
    NSMutableArray *_players;
    BOOL _mute;
}

- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

+ (instancetype)instance
{
    static JMSSoundHelper *anInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        anInstance = [[JMSSoundHelper alloc] init];
    });
    return anInstance;
}

- (NSMutableArray *) players
{
    if (_players == nil)
    {
        _players = [[NSMutableArray alloc] init];
    }
    return _players;
}


- (AVAudioPlayer *)audioPlayerForSoundAction:(JMSSoundAction)soundAction
{
    NSURL *soundUrl = [[NSBundle mainBundle] URLForResource:[self soundNameByAction:soundAction] withExtension:@"wav"];
    
    NSMutableArray* availablePlayers = [[self players] mutableCopy];
    
    NSPredicate *filteringPredicate = [NSPredicate predicateWithBlock:^BOOL(AVAudioPlayer *evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject.playing == NO && [evaluatedObject.url isEqual:soundUrl];
    }];
    
    [availablePlayers filterUsingPredicate:filteringPredicate];
    
    if (availablePlayers.count > 0)
    {
        return [availablePlayers firstObject];
    }
    
    NSError *error = nil;
    AVAudioPlayer* newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
    
    if (newPlayer == nil)
    {
        NSLog(@"Couldn't load %@: %@", soundUrl, error);
        return nil;
    }
    
    [[self players] addObject:newPlayer];
    
    return newPlayer;
    
}

- (NSString *)soundNameByAction:(JMSSoundAction)soundAction
{
    switch (soundAction)
    {
        case JMSSoundActionGameFailed:
            return @"game_over";
        case JMSSoundActionCellTap:
            return @"ui_feedback";
        case JMSSoundActionLevelCompleted:
            return @"level_completed";
        case JMSSoundActionMenuButtonClick:
            return @"menu_button_click";
        case JMSSoundActionPutFlag:
            return @"put_flag";
        default:
            return nil;
    }
}

- (void)mute:(BOOL)mute
{
    _mute = mute;
}

- (void)playSoundWithAction:(JMSSoundAction)soundAction
{
    if (_mute) return;
    
    AVAudioPlayer *player = [self audioPlayerForSoundAction:soundAction];
    [player play];
}


@end
