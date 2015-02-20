//
//  JMSSoundManager.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/20/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSSoundManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation JMSSoundManager
{
    SystemSoundID pewPewSound;
}
- (void)playSoundAction:(JMSSoundAction)soundAction
{
    NSString *soundResourceFileName;
    switch (soundAction)
    {
        case JMSSoundActionGameFailed:
            soundResourceFileName = @"game_over";
            break;
        case JMSSoundActionCellTap:
            soundResourceFileName = @"ui_feedback";
            break;
        case JMSSoundActionLevelCompleted:
            soundResourceFileName = @"level_completed";
            break;
        default:
            return;
    }
    
    NSURL *soundResourceURL = [[NSBundle mainBundle] URLForResource:soundResourceFileName withExtension:@"wav"];
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundResourceURL, &pewPewSound);
    AudioServicesPlaySystemSound(pewPewSound);
    return;
    NSError* error = nil;
    
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundResourceURL
                                                                        error:&error];
    
    if (error != nil)
    {
        NSLog(@"Failed to load the sound: %@", [error localizedDescription]);
    }
    
    [audioPlayer play];

}

@end
