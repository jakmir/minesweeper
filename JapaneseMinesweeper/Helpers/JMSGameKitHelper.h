//
//  JMSGameKitHelper.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/15/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>

@import GameKit;

extern NSString *const kPresentAuthenticationViewController;

@interface JMSGameKitHelper : NSObject

@property (nonatomic, readonly) UIViewController *authenticationViewController;
@property (nonatomic, readonly) NSError *lastError;

+ (instancetype)instance;
- (void)authenticateLocalPlayer;

@end
