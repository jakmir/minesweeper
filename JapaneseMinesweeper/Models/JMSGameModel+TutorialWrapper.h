//
//  JMSGameModel+Tutorial.h
//  JapaneseMinesweeper
//
//  Created by Denis on 6/10/19.
//  Copyright © 2019 Jakmir. All rights reserved.
//

#import "JMSGameModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JMSGameModel (TutorialWrapper)

- (void)fillTutorialMapWithLevel:(NSUInteger)level;

@end

NS_ASSUME_NONNULL_END
