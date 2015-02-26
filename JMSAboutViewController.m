//
//  JMSAboutViewController.m
//  JapaneseMinesweeper
//
//  Created by Denys Melnyk on 2/26/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSAboutViewController.h"

@interface JMSAboutViewController ()
{
    UIPanGestureRecognizer *panGestureRecognizer;
}
@end

@implementation JMSAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper"]];
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowOffset = CGSizeZero;
    self.view.layer.shadowRadius = 6;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds cornerRadius:0].CGPath;
    
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            self.view.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2,
                                                           [[UIScreen mainScreen] bounds].size.height - 100);
                        } completion:nil];
}

- (void)dealloc
{
    for (UIGestureRecognizer *gestureRecognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:gestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drag:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            self.view.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2,
                                                           [[UIScreen mainScreen] bounds].size.height + CGRectGetHeight(self.view.frame));
                        } completion:^(BOOL finished) {
                            if (finished)
                            {
                                [self.view removeFromSuperview];
                                [self removeFromParentViewController];
                            }
                        }];
    }
}

@end
