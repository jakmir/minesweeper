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
#import "JMSGameKitHelper.h"
#import "JMSAboutViewController.h"
#import "JMSMainView.h"
#import "JMSAboutView.h"

@interface JMSMainViewController ()

@property (nonatomic, strong) JMSAboutViewController *aboutViewController;
@property (nonatomic, readonly) JMSMainView *mainView;
@property (nonatomic, readonly) JMSAboutView *aboutView;

@end

@implementation JMSMainViewController

#pragma mark - Life Cycle methods and events

- (void)viewDidLoad {
    [super viewDidLoad];

    self.aboutViewController = [[JMSAboutViewController alloc] initWithNibName:@"JMSAboutViewController" bundle:nil];
    
    [self addChildViewController:self.aboutViewController];
    [self.mainView addSubview:[self aboutView]];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handlePan:)];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleMainScreenTouch:)];
    [self.aboutView addGestureRecognizer:panRecognizer];
    [self.mainView addGestureRecognizer:tapGestureRecognizer];
    [self.aboutView hideAboutView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIImage *wallpaperImage = [UIImage imageNamed:@"wallpaper"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:wallpaperImage];
    
    [self.mainView updateButtonsWithModel:self.gameModel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.mainView drawGradients];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAuthenticationViewController)
                                                 name:kPresentAuthenticationViewController
                                               object:nil];
    [[JMSGameKitHelper instance] authenticateLocalPlayer];
   
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Access Properties

- (JMSMainView *)mainView {
    if ([self.view isKindOfClass:[JMSMainView class]]) {
        return (JMSMainView *)self.view;
    }
    return nil;
}

- (JMSAboutView *)aboutView {
    if ([self.aboutViewController.view isKindOfClass:[JMSAboutView class]]) {
        return (JMSAboutView *)self.aboutViewController.view;
    }
    return nil;
}

- (void)setGameModel:(JMSGameModel *)gameSessionInfo {
    _gameModel = gameSessionInfo;
    
    [self.mainView updateButtonsWithModel:gameSessionInfo];
}


#pragma mark - GameKit methods

- (void)showAuthenticationViewController {
    JMSGameKitHelper *gameKitHelper = [JMSGameKitHelper instance];
    
    [self presentViewController:gameKitHelper.authenticationViewController
                       animated:YES
                     completion:nil];
}

#pragma mark - Screen transition methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.aboutView hideAboutView];
    
    if ([segue.identifier isEqualToString:@"toGame"]) {
        JMSGameBoardViewController *destinationController = (JMSGameBoardViewController *)segue.destinationViewController;
        destinationController.mainViewController = self;
        destinationController.gameModel = self.gameModel;
    }
}

#pragma mark - About screen methods

- (IBAction)showAboutScreen:(UIButton *)sender {
    [self.aboutView animateShowView];
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    static CGPoint oldCenter;
    
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            oldCenter = gestureRecognizer.view.center;
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translatedPoint = [gestureRecognizer translationInView:self.view];
            if (translatedPoint.y > 0) {
                gestureRecognizer.view.center = CGPointMake(oldCenter.x, oldCenter.y + translatedPoint.y);
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (gestureRecognizer.view.center.y - oldCenter.y < CGRectGetHeight(gestureRecognizer.view.frame) / 4) {
                [self.aboutView animateJumpBack];
            }
            else {
                [self.aboutView animateHideViewWithVelocity:[gestureRecognizer velocityInView:self.view].y / 200.0];
            }
        }
            break;
        default:
            break;
    }
}

- (void)handleMainScreenTouch:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.aboutView.isViewInScreen) {
        [self.aboutView animateHideViewWithVelocity:1];
    }
}

@end
