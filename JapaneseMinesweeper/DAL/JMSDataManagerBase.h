//
//  JMSDataManagerBase.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/16/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMSAppDelegate.h"

@interface JMSDataManagerBase : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
