//
//  JMSTutorialTask.m
//  JapaneseMinesweeper
//
//  Created by Denys Melnyk on 3/26/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSTutorialTask.h"

@implementation JMSTutorialTask

- (instancetype)initWithPosition:(JMSPosition)position action:(JMSAllowedAction)action {
    if (self = [super init]) {
        _position = position;
        _action = action;
        _completed = NO;
    }
    return self;
}

- (void)setCompleted:(BOOL)completed {
    if (completed) {
        _completed = completed;
    }
}

@end
