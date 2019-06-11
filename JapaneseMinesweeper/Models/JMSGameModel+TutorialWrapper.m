//
//  JMSGameModel+Tutorial.m
//  JapaneseMinesweeper
//
//  Created by Denis on 6/10/19.
//  Copyright © 2019 Jakmir. All rights reserved.
//

#import "JMSGameModel+TutorialWrapper.h"
#import "JMSMapModel+Tutorial.h"

@implementation JMSGameModel (TutorialWrapper)

- (void)fillTutorialMapWithLevel:(NSUInteger)level {
    [self.mapModel fillTutorialMapWithLevel:level];
}

@end
