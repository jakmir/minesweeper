//
//  JMSPopoverPresentationController.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/25/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSPopoverPresentationController.h"

@implementation JMSPopoverPresentationController

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    NSLog(@"delegate method called asking permission to dismiss popover");
    return YES;
}

@end
