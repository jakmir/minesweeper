//
//  JMSGameSession.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/16/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface JMSGameSession : NSManagedObject

@property (nonatomic, retain) NSNumber *score;
@property (nonatomic, retain) NSNumber *level;
@property (nonatomic, retain) NSNumber *progress;
@property (nonatomic, retain) NSDate *postedAt;

@end
