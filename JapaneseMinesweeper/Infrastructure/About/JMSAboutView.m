//
//  JMSAboutView.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/4/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import "JMSAboutView.h"

@implementation JMSAboutView

- (CGFloat)extraOffset {
    return 100;
}

- (void)animateShowView {
    [UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            self.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2,
                                                      [[UIScreen mainScreen] bounds].size.height - [self extraOffset]);
                        } completion:nil];
    
}

- (void)animateHideViewWithVelocity:(CGFloat)velocity {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    [UIView animateWithDuration:2.25 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:velocity
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            self.center = CGPointMake(bounds.size.width / 2,
                                                      bounds.size.height + self.frame.size.height);
                        } completion:nil];
}

- (void)hideAboutView {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetHeight(bounds) + CGRectGetHeight(self.frame));
}

- (void)animateJumpBack {
    CGFloat timeMultiplier = -(self.center.y - [[UIScreen mainScreen] bounds].size.height + [self extraOffset]) / self.frame.size.height;
    [UIView animateWithDuration:2.25 * timeMultiplier
                          delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.25
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            self.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2,
                                                      [[UIScreen mainScreen] bounds].size.height - [self extraOffset]);
                        } completion:nil];
}

- (BOOL)isViewInScreen {
    CGRect intersection = CGRectIntersection([[UIScreen mainScreen] bounds], self.frame);
    return !CGSizeEqualToSize(intersection.size, CGSizeZero);
    
}
@end
