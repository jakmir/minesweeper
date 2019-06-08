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

@interface JMSMessageBoxView()

@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic, strong) void (^onButtonTouchUpInside)(void);

@end

@implementation JMSMessageBoxView

- (instancetype)initWithButtonTitle:(NSString *)title actionHandler:(void (^)(void))onButtonTouchUpInsideHandler {
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;

        self.useMotionEffects = NO;
        self.buttonTitle = title;
        self.onButtonTouchUpInside = onButtonTouchUpInsideHandler;
    }
    return self;
}

// Create the dialog view, and animate opening the dialog
- (void)show {
    self.dialogView = [self createContainerView];
    
    self.dialogView.layer.shouldRasterize = YES;
    self.dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.dialogView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
#if (defined(__IPHONE_7_0))
    if (self.useMotionEffects) {
        [self applyMotionEffects];
    }
#endif
    
    self.dialogView.layer.opacity = 0.5f;
    self.dialogView.layer.transform = CATransform3DMakeScale(0.3f, 0.3f, 1.0);
    
    self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1.0 alpha:0.0];
    
    [self addSubview:self.dialogView];
    
    [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    
    UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageBoxTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    [UIView animateWithDuration:1.0
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.25
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25f];
                         self.dialogView.layer.opacity = 1.0f;
                         self.dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:nil
     ];
}

- (void)dismissMessageBox {
    CATransform3D currentTransform = self.dialogView.layer.transform;
    
    self.dialogView.layer.opacity = 1.0f;
    
    for (UIGestureRecognizer *gestureRecognizer in self.gestureRecognizers) {
        [self removeGestureRecognizer:gestureRecognizer];
    }
    
    [UIView animateWithDuration:0.5f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         self.dialogView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }
     ];
}

- (void)close {
    self.onButtonTouchUpInside();
    
    [self dismissMessageBox];
}

- (void)messageBoxTap:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint touchLocation = [gestureRecognizer locationInView:self.dialogView];
    if (!CGRectContainsPoint(self.dialogView.bounds, touchLocation)) {
        [self dismissMessageBox];
    }
}

// TODO: needs heavy refactoring, too much archaic calculation and magic numbers
- (UIView *)createContainerView {
    if (self.containerView == NULL) {
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    }
    
    CGSize screenSize = [self screenSize];
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
    
    [dialogContainer addSubview:self.containerView];
    
    [self addButtonsToView:dialogContainer];
    
    return dialogContainer;
}

// TODO: needs heavy refactoring, too much archaic calculation and magic numbers
- (void)addButtonsToView:(UIView *)container {
    CGFloat buttonWidthModifier = 0.8;
    CGFloat buttonWidth = container.bounds.size.width * buttonWidthModifier;
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(container.bounds.size.width * (1 - buttonWidthModifier) / 2,
                                                                      container.bounds.size.height - kMessageBoxDefaultButtonHeight - 16,
                                                                      buttonWidth,
                                                                      kMessageBoxDefaultButtonHeight)];

    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    [closeButton setTitle:self.buttonTitle ?: @"Ok" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor colorFromInteger:0xffffffff] forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor colorFromInteger:0x7f494949] forState:UIControlStateHighlighted];
    [closeButton.titleLabel setFont:[UIFont systemFontOfSize:19 weight:UIFontWeightMedium]];
    [closeButton setBackgroundColor:[UIColor colorFromInteger:0xffff7f00]];
    [closeButton.layer setBorderColor:[UIColor colorFromInteger:0xffff6600].CGColor];
    [closeButton.layer setBorderWidth:1.0f];
    [closeButton.layer setCornerRadius:kMessageBoxCornerRadius];
    [closeButton.layer masksToBounds];
    [container addSubview:closeButton];
}

- (CGSize)countDialogSize {
    CGFloat dialogWidth = self.containerView.frame.size.width;
    CGFloat dialogHeight = self.containerView.frame.size.height + kMessageBoxDefaultButtonHeight;
    return CGSizeMake(dialogWidth, dialogHeight);
}

- (CGSize)screenSize {
    return [UIScreen mainScreen].bounds.size;
}

#if (defined(__IPHONE_7_0))
- (void)applyMotionEffects {
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
    
    [self.dialogView addMotionEffect:motionEffectGroup];
}
#endif

@end
