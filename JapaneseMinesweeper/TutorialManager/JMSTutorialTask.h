//
//  JMSTutorialTask.h
//  JapaneseMinesweeper
//
//  Created by Denys Melnyk on 3/26/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enums.h"
#import "Structs.h"

@interface JMSTutorialTask : NSObject

@property (nonatomic) JMSPosition position;
@property (nonatomic) JMSAllowedAction action;
@property (nonatomic) BOOL done;

- (instancetype)initWithPosition:(JMSPosition)position action:(JMSAllowedAction)action;

@end
