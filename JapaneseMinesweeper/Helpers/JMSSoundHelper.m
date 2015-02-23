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
    AVAudioPlayer *cellTouchAudioPlayer;
    AVAudioPlayer *putFlagAudioPlayer;
    AVAudioPlayer *player;
}

- (id)init
{
    if (self = [super init])
    {
        cellTouchAudioPlayer = [self createAudioPlayerForSoundAction:JMSSoundActionCellTap];
        putFlagAudioPlayer = [self createAudioPlayerForSoundAction:JMSSoundActionPutFlag];
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

- (void) preparePlayers
{
    if (cellTouchAudioPlayer) [cellTouchAudioPlayer prepareToPlay];
    if (putFlagAudioPlayer) [putFlagAudioPlayer prepareToPlay];
}

- (AVAudioPlayer *)createAudioPlayerForSoundAction:(JMSSoundAction)soundAction
{
    NSError *error = nil;
    
    NSURL *soundUrl = [[NSBundle mainBundle] URLForResource:[self soundNameByAction:soundAction] withExtension:@"wav"];
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
    if (error != nil)
    {
        NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
    }
    return audioPlayer;
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

- (void)playSoundWithAction:(JMSSoundAction)soundAction
{
    switch (soundAction)
    {
        case JMSSoundActionGameFailed:
            player = [self createAudioPlayerForSoundAction:JMSSoundActionGameFailed];
            break;
        case JMSSoundActionCellTap:
            player = cellTouchAudioPlayer;
            break;
        case JMSSoundActionLevelCompleted:
            player = [self createAudioPlayerForSoundAction:JMSSoundActionLevelCompleted];
            break;
        case JMSSoundActionMenuButtonClick:
            player = [self createAudioPlayerForSoundAction:JMSSoundActionMenuButtonClick];
            break;
        case JMSSoundActionPutFlag:
            player = putFlagAudioPlayer;
            break;
        default:
            player = nil;
    }
    if (player.isPlaying)
    {
        NSLog(@"stopped");
        [player stop];
        [player setCurrentTime:0];
    }
    [player play];
}


@end
