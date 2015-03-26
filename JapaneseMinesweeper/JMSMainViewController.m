//
//  ViewController.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/12/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "JMSMainViewController.h"
#import "JMSGameBoardViewController.h"
#import "UIColor+ColorFromHexString.h"
#import "Helpers/JMSGameKitHelper.h"
#import "JMSAboutViewController.h"

@interface JMSMainViewController ()
{
    JMSAboutViewController *aboutViewController;
}
@end

@implementation JMSMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    aboutViewController = [[JMSAboutViewController alloc] initWithNibName:@"JMSAboutViewController" bundle:nil];
    
    [self addChildViewController:aboutViewController];
    [self.view addSubview:aboutViewController.view];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handlePan:)];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleMainScreenTouch:)];
    [aboutViewController.view addGestureRecognizer:panRecognizer];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    [self hideAboutView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIImage *wallpaperImage = [UIImage imageNamed:@"wallpaper"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:wallpaperImage];
    [self updateButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    for (JMSGradientButton *gradientButton in self.gradientButtons)
    {
        [gradientButton drawGradientWithStartColor:[UIColor colorFromInteger:0xff00cfff]
                                    andFinishColor:[UIColor colorFromInteger:0xff007fff]];
        [gradientButton.layer setCornerRadius:16];
        [gradientButton.layer setMasksToBounds:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAuthenticationViewController)
                                                 name:kPresentAuthenticationViewController
                                               object:nil];
    [[JMSGameKitHelper instance] authenticateLocalPlayer];
   
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray *)gradientButtons
{
    return @[self.btnStart, self.btnLeaderboard, self.btnComplexityLevel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)updateButtons
{
    [self.btnStart setTitle:_gameSessionInfo != nil ? @"Continue" : @"New game" forState:UIControlStateNormal];

    CGFloat heightSum = 0;
    for (JMSGradientButton *gradientButton in [self gradientButtons])
    {
        heightSum += CGRectGetHeight(gradientButton.frame);
    }
    CGSize size = self.buttonListContainer.frame.size;
    CGFloat interval = (size.height - heightSum) / ([self gradientButtons].count - 1);
    
    CGFloat y = 0;
    for (JMSGradientButton *gradientButton in [self gradientButtons])
    {
        gradientButton.center = CGPointMake(size.width / 2, y + CGRectGetHeight(gradientButton.frame) / 2);
        y += CGRectGetHeight(gradientButton.frame) + interval;
    }
}

- (void)setGameSessionInfo:(JMSGameSessionInfo *)gameSessionInfo
{
    _gameSessionInfo = gameSessionInfo;
    
    [self updateButtons];
}


#pragma mark - GameKit methods

- (void)showAuthenticationViewController
{
    JMSGameKitHelper *gameKitHelper = [JMSGameKitHelper instance];
    
    [self presentViewController:gameKitHelper.authenticationViewController
                       animated:YES
                     completion:nil];
}

#pragma mark - screen transition methods

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self hideAboutView];
    
    if ([segue.identifier isEqualToString:@"toGame"])
    {
        JMSGameBoardViewController *destinationController = (JMSGameBoardViewController *)segue.destinationViewController;
        destinationController.mainViewController = self;
    }
}

#pragma mark - about screen methods

- (IBAction)showAboutScreen:(UIButton *)sender
{
    [self animateShowView];
}

- (void)animateShowView
{
    NSLog(@"%s", __FUNCTION__);
    [UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            aboutViewController.view.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2,
                                                                          [[UIScreen mainScreen] bounds].size.height - 100);
                        } completion:^(BOOL finished) {
                        }];

}

- (void)animateHideViewWithVelocity:(CGFloat)velocity;
{
    NSLog(@"%s", __FUNCTION__);
    [UIView animateWithDuration:2.25 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:velocity
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            aboutViewController.view.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2,
                                                                          [[UIScreen mainScreen] bounds].size.height + aboutViewController.view.frame.size.height);
                        } completion:^(BOOL finished) {
                        }];
}

- (void)hideAboutView
{
    aboutViewController.view.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2,
                                                  [[UIScreen mainScreen] bounds].size.height + aboutViewController.view.frame.size.height);
}

- (void)animateJumpBack
{
    CGFloat timeMultiplier = -(aboutViewController.view.center.y - [[UIScreen mainScreen] bounds].size.height + 100) /
                                aboutViewController.view.frame.size.height;
    [UIView animateWithDuration:2.25 * timeMultiplier
                          delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.25
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            aboutViewController.view.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2,
                                                                          [[UIScreen mainScreen] bounds].size.height - 100);
                        } completion:nil];
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    static CGPoint oldCenter;
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            oldCenter = gestureRecognizer.view.center;
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translatedPoint = [gestureRecognizer translationInView:self.view];
            if (translatedPoint.y > 0)
            {
                gestureRecognizer.view.center = CGPointMake(oldCenter.x, oldCenter.y + translatedPoint.y);
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (gestureRecognizer.view.center.y - oldCenter.y < CGRectGetHeight(gestureRecognizer.view.frame) / 4)
            {
                [self animateJumpBack];
            }
            else
            {
                [self animateHideViewWithVelocity:[gestureRecognizer velocityInView:self.view].y / 200.0];
            }
        }
            break;
        default:
            break;
    }
}

- (void)handleMainScreenTouch:(UITapGestureRecognizer *)gestureRecognizer
{
    if (aboutViewController.isInScreen)
    {
        [self animateHideViewWithVelocity:1];
    }
}
@end
