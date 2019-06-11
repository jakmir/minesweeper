//
//  JMSSoundHelper.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/23/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSSoundHelper.h"
#import <AVFoundation/AVFoundation.h>

@interface JMSSoundHelper()

@property (nonatomic) BOOL isMuted;
@property (nonatomic) SystemSoundID soundId;

@end

@implementation JMSSoundHelper

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

+ (instancetype)shared {
    static JMSSoundHelper *anInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        anInstance = [[JMSSoundHelper alloc] init];
    });
    return anInstance;
}

- (NSString *)soundNameByAction:(JMSSoundAction)soundAction {
    switch (soundAction) {
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

- (void)muteSound:(BOOL)mute {
    _isMuted = mute;
}

- (void)playSoundWithAction:(JMSSoundAction)soundAction {
    if (_isMuted) {
        return;
    }
    NSString *soundPath = [[NSBundle mainBundle]
                            pathForResource:[self soundNameByAction:soundAction] ofType:@"wav"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &_soundId);
    AudioServicesPlaySystemSound(self.soundId);
    
}

@end
