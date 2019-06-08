//
//  JMSGameKitHelper.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/15/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSGameKitHelper.h"

NSString *const kPresentAuthenticationViewController = @"notificationPresentAuthenticationViewController";

@interface JMSGameKitHelper()

@property (nonatomic) BOOL gameCenterEnabled;

@end


@implementation JMSGameKitHelper

- (instancetype)init {
    if (self = [super init]) {
        _gameCenterEnabled = YES;
    }
    return self;
}

+ (instancetype)instance
{
    static JMSGameKitHelper *anInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        anInstance = [[JMSGameKitHelper alloc] init];
    });
    return anInstance;
}

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        [self setLastError:error];
        
        if (viewController != nil) {
           [self setAuthenticationViewController:viewController];
        }
        else {
            self.gameCenterEnabled = [GKLocalPlayer localPlayer].isAuthenticated;
        }
    };
}

- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController {
    if (authenticationViewController != nil) {
        _authenticationViewController = authenticationViewController;
        [[NSNotificationCenter defaultCenter] postNotificationName:kPresentAuthenticationViewController object:self];
    }
}

- (void)setLastError:(NSError *)error {
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"Error occured in GameKitHelper: %@", [[_lastError userInfo] description]);
    }
}
@end
