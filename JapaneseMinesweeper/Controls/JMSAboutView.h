//
//  JMSAboutView.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/4/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMSAboutView : UIView

- (void)animateShowView;
- (void)hideAboutView;
- (void)animateJumpBack;
- (void)animateHideViewWithVelocity:(CGFloat)velocity;
- (BOOL)isViewInScreen;

@end
