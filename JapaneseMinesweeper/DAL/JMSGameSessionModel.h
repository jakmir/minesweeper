//
//  JMSGameSessionModel.h
//  JapaneseMinesweeper
//
//  Created by Denys Melnyk on 5/28/19.
//  Copyright © 2019 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JMSGameSessionModel : NSObject

@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger level;
@property (nonatomic) double progress;
@property (nonatomic, strong) NSDate *postedAt;

@end

NS_ASSUME_NONNULL_END
