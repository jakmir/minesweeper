//
//  JMSDataManagerBase.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/16/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSDataManagerBase.h"

@implementation JMSDataManagerBase

- (instancetype) init
{
    if (self = [super init])
    {
        JMSAppDelegate *appDelegate = (JMSAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [appDelegate managedObjectContext];
    }
    return self;
}

@end
