//
//  ViewController.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/12/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "MainViewController.h"
#import "JMSGameBoardViewController.h"
#import "UIColor+ColorFromHexString.h"
#import "Helpers/JMSGameKitHelper.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray *)gradientButtons
{
    return @[self.btnStart, self.btnLeaderboard, self.btnComplexityLevel, self.btnTutorial];
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
    [self.btnStart setTitle:self.gameSessionInfo ? @"Continue" : @"New game" forState:UIControlStateNormal];

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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toGame"])
    {
        JMSGameBoardViewController *destinationController = (JMSGameBoardViewController *)segue.destinationViewController;
        destinationController.mainViewController = self;
    }
}

#pragma mark - GameKit methods

- (void)showAuthenticationViewController
{
    JMSGameKitHelper *gameKitHelper = [JMSGameKitHelper instance];
    
    [self presentViewController:gameKitHelper.authenticationViewController
                       animated:YES
                     completion:nil];
}
@end
