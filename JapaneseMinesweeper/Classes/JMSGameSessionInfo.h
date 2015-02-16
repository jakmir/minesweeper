//
//  JMSGameSessionInfo.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/14/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMSGameSessionInfo : NSObject

@property (nonatomic) NSUInteger score;
@property (nonatomic) NSUInteger level;
@property (nonatomic, strong) NSArray *map;

- (NSUInteger)markedCellsCount;

@end
