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
    return CGRectGetHeight(self.bounds) * 0.4;
}

- (CGFloat)showAnimationDuration {
    return 1.5;
}

- (CGFloat)hideAnimationDuration {
    return 2.25;
}

- (CGFloat)damping {
    return 0.7;
}
- (CGPoint)middleBottomPointWithOffset:(CGFloat)offset {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    return CGPointMake(CGRectGetMidX(bounds), CGRectGetHeight(bounds) + offset);
}

- (void)animateShowView {
    [UIView animateWithDuration:[self showAnimationDuration]
                          delay:0
         usingSpringWithDamping:[self damping]
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            self.center = [self middleBottomPointWithOffset:-[self extraOffset]];
                        } completion:nil];
    
}

- (void)animateHideViewWithVelocity:(CGFloat)velocity {
    [UIView animateWithDuration:[self hideAnimationDuration]
                          delay:0
         usingSpringWithDamping:[self damping]
          initialSpringVelocity:velocity
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            [self hide];
                        } completion:nil];
}

- (void)hide {
    self.center = [self middleBottomPointWithOffset:CGRectGetHeight(self.frame)];
}

- (void)animateJumpBack {
    CGFloat timeMultiplier = -(self.center.y - [[UIScreen mainScreen] bounds].size.height + [self extraOffset]) / CGRectGetHeight(self.frame);
    [UIView animateWithDuration:[self hideAnimationDuration] * timeMultiplier
                          delay:0
         usingSpringWithDamping:[self damping]
          initialSpringVelocity:0.25
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            [self hide];
                        } completion:nil];
}

- (BOOL)isViewInScreen {
    CGRect intersection = CGRectIntersection([[UIScreen mainScreen] bounds], self.frame);
    return !CGSizeEqualToSize(intersection.size, CGSizeZero);
}

@end
