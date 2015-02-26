//
//  JMSMessageBoxView.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/24/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSMessageBoxView.h"
#import <QuartzCore/QuartzCore.h>
#import "JMSGradientButton.h"
#import "UIColor+ColorFromHexString.h"

const static CGFloat kMessageBoxDefaultButtonHeight = 50;
const static CGFloat kMessageBoxCornerRadius = 12;
const static CGFloat kMessageBoxMotionEffectExtent = 10.0;

@implementation JMSMessageBoxView

CGFloat buttonHeight = 0;

@synthesize containerView, dialogView, onButtonTouchUpInside;
@synthesize buttonTitle;
@synthesize useMotionEffects;

- (instancetype)initWithButtonTitle:(NSString *)title actionHandler:(void (^)(void))onButtonTouchUpInsideHandler
{
    self = [super init];
    if (self)
    {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

        useMotionEffects = false;
        buttonTitle = title;
        onButtonTouchUpInside = onButtonTouchUpInsideHandler;
    }
    return self;
}

// Create the dialog view, and animate opening the dialog
- (void)show
{
    dialogView = [self createContainerView];
    
    dialogView.layer.shouldRasterize = YES;
    dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    dialogView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
#if (defined(__IPHONE_7_0))
    if (useMotionEffects)
    {
        [self applyMotionEffects];
    }
#endif
    
    dialogView.layer.opacity = 0.5f;
    dialogView.layer.transform = CATransform3DMakeScale(0.3f, 0.3f, 1.0);
    
    self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1.0 alpha:0.0];
    
    [self addSubview:dialogView];
    
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    
    [UIView animateWithDuration:1.0f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25f];
                         dialogView.layer.opacity = 1.0f;
                         dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:NULL
     ];
}

// Dialog close animation then cleaning and removing the view from the parent
- (void)close
{
    onButtonTouchUpInside();
    
    CATransform3D currentTransform = dialogView.layer.transform;
    
    dialogView.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.5f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         dialogView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }
     ];
}

- (void)setSubView: (UIView *)subView
{
    containerView = subView;
}

- (UIView *)createContainerView
{
    if (containerView == NULL) {
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    }
    
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    
    [self setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2,
                                                                       (screenSize.height - dialogSize.height) / 2,
                                                                       dialogSize.width,
                                                                       dialogSize.height)];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = dialogContainer.bounds;
    gradient.colors = @[
                       (id)[[UIColor colorFromInteger:0xf0dfdfdf] CGColor],
                       (id)[[UIColor colorFromInteger:0xf0f9f9f9] CGColor],
                       (id)[[UIColor colorFromInteger:0xf0dfdfdf] CGColor]
                       ];
    
    CGFloat cornerRadius = kMessageBoxCornerRadius;
    gradient.cornerRadius = cornerRadius;
    [dialogContainer.layer insertSublayer:gradient atIndex:0];
    
    dialogContainer.layer.cornerRadius = cornerRadius;
    dialogContainer.layer.shadowRadius = cornerRadius + 8;
    dialogContainer.layer.shadowOpacity = 0.5f;
    dialogContainer.layer.shadowOffset = CGSizeZero;
    dialogContainer.layer.shadowColor = [UIColor whiteColor].CGColor;
    dialogContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:dialogContainer.bounds
                                                                  cornerRadius:dialogContainer.layer.cornerRadius].CGPath;
    
    [dialogContainer addSubview:containerView];
    
    [self addButtonsToView:dialogContainer];
    
    return dialogContainer;
}

- (void)addButtonsToView: (UIView *)container
{
    CGFloat buttonWidthModifier = 0.8;
    CGFloat buttonWidth = container.bounds.size.width * buttonWidthModifier;
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(container.bounds.size.width * (1 - buttonWidthModifier) / 2,
                                                                      container.bounds.size.height - buttonHeight - 16,
                                                                      buttonWidth,
                                                                      buttonHeight)];

    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    [closeButton setTitle:buttonTitle ?: @"Ok" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor colorFromInteger:0xffffffff] forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor colorFromInteger:0x7f494949] forState:UIControlStateHighlighted];
    [closeButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:19]];
    [closeButton setBackgroundColor:[UIColor colorFromInteger:0xffff7f00]];
    [closeButton.layer setBorderColor:[UIColor colorFromInteger:0xffff6600].CGColor];
    [closeButton.layer setBorderWidth:1.0f];
    [closeButton.layer setCornerRadius:kMessageBoxCornerRadius];
    [closeButton.layer masksToBounds];
    [container addSubview:closeButton];
}

- (CGSize)countDialogSize
{
    CGFloat dialogWidth = containerView.frame.size.width;
    CGFloat dialogHeight = containerView.frame.size.height + buttonHeight;
    
    return CGSizeMake(dialogWidth, dialogHeight);
}


- (CGSize)countScreenSize
{
    buttonHeight = kMessageBoxDefaultButtonHeight;

    return [UIScreen mainScreen].bounds.size;
}

#if (defined(__IPHONE_7_0))
- (void)applyMotionEffects
{
    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                    type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = @(-kMessageBoxMotionEffectExtent);
    horizontalEffect.maximumRelativeValue = @( kMessageBoxMotionEffectExtent);
    
    UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                  type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalEffect.minimumRelativeValue = @(-kMessageBoxMotionEffectExtent);
    verticalEffect.maximumRelativeValue = @( kMessageBoxMotionEffectExtent);
    
    UIMotionEffectGroup *motionEffectGroup = [[UIMotionEffectGroup alloc] init];
    motionEffectGroup.motionEffects = @[horizontalEffect, verticalEffect];
    
    [dialogView addMotionEffect:motionEffectGroup];
}
#endif



@end
