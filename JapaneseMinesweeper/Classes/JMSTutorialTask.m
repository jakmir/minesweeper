//
//  JMSTutorialTask.m
//  JapaneseMinesweeper
//
//  Created by Denys Melnyk on 3/26/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSTutorialTask.h"

@implementation JMSTutorialTask

- (instancetype)initWithPosition:(struct JMSPosition)position action:(JMSAllowedAction)action
{
    if (self = [super init])
    {
        _position = position;
        _action = action;
        _done = NO;
    }
    return self;
}

- (void)setDone:(BOOL)done
{
    if (_done && !done) return;
    _done = done;
}

@end
