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
#import "UIView+MakeFitToEdges.h"

const static CGFloat kMessageBoxCornerRadius = 12;
const static CGFloat kMessageBoxMotionEffectExtent = 10.0;

@interface JMSMessageBoxView()

@property (nonatomic, strong) NSString *buttonTitle;

@property (nonatomic, strong) IBOutlet UILabel *lbCaption;
@property (nonatomic, strong) IBOutlet UILabel *lbDescription;
@property (nonatomic, strong) IBOutlet UIButton *btnAction;

@property (nonatomic, strong) IBOutlet UIView *containerView;

@property (nonatomic, strong) IBOutlet UIView *contentView;

@end

@implementation JMSMessageBoxView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configure];
    }
    return self;
}

#pragma mark -
#pragma mark UI Configuration Methods

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
    
    [self.containerView addMotionEffect:motionEffectGroup];
}

- (void)configure {
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    
    [self makeFitToEdges:self.contentView];
    
    [self configureTitles];
    [self applyMotionEffects];
    [self configureLayers];
    [self configureButtons];
    
    UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMessageBoxTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)configureTitles {
    self.lbCaption.text = NSLocalizedString(@"You won this round", nil);
    self.lbDescription.text = NSLocalizedString(@"Congratulations", nil);
    [self.btnAction setTitle:NSLocalizedString(@"Play again Btn", nil)
                    forState:UIControlStateNormal];
    [self.btnAction setTitle:NSLocalizedString(@"Play again Btn", nil)
                    forState:UIControlStateHighlighted];
}

- (void)configureLayers {
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.containerView.bounds;
    gradient.colors = @[
                        (id)[[UIColor colorFromInteger:0xf0dfdfdf] CGColor],
                        (id)[[UIColor colorFromInteger:0xf0f9f9f9] CGColor],
                        (id)[[UIColor colorFromInteger:0xf0dfdfdf] CGColor]
                        ];
    
    CGFloat cornerRadius = kMessageBoxCornerRadius;
    gradient.cornerRadius = cornerRadius;
    
    CALayer *containerLayer = self.containerView.layer;
    [containerLayer insertSublayer:gradient atIndex:0];
    containerLayer.shouldRasterize = YES;
    containerLayer.rasterizationScale = [[UIScreen mainScreen] scale];
    containerLayer.cornerRadius = kMessageBoxCornerRadius;
    containerLayer.shadowRadius = kMessageBoxCornerRadius + 8;
    containerLayer.shadowOpacity = 0.5f;
    containerLayer.shadowOffset = CGSizeZero;
    containerLayer.shadowColor = [UIColor whiteColor].CGColor;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds
                                                    cornerRadius:containerLayer.cornerRadius];
    containerLayer.shadowPath = path.CGPath;
    
    self.containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
}

- (void)configureButtons {
    [self.btnAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnAction setTitleColor:[UIColor colorFromInteger:0x7f494949] forState:UIControlStateHighlighted];
    [self.btnAction.titleLabel setFont:[UIFont systemFontOfSize:19 weight:UIFontWeightMedium]];
    [self.btnAction setBackgroundColor:[UIColor colorFromInteger:0xffff7f00]];
    [self.btnAction.layer setBorderColor:[UIColor colorFromInteger:0xffff6600].CGColor];
    [self.btnAction.layer setBorderWidth:1.0f];
    [self.btnAction.layer setCornerRadius:kMessageBoxCornerRadius];
    [self.btnAction.layer masksToBounds];
    
}

#pragma mark Actions

- (void)handleMessageBoxTap:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint touchLocation = [gestureRecognizer locationInView:self.containerView];
    if (!CGRectContainsPoint(self.containerView.bounds, touchLocation)) {
        [self hide];
    }
}

- (void)show {
    self.containerView.layer.opacity = 0.5f;
    self.containerView.layer.transform = CATransform3DMakeScale(0.3f, 0.3f, 1.0);
    
    [UIView animateWithDuration:1.0
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.25
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25f];
                         self.containerView.layer.opacity = 1.0f;
                         self.containerView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:nil
     ];
}

- (void)hide {
    CATransform3D currentTransform = self.containerView.layer.transform;
    
    self.containerView.layer.opacity = 1.0f;
    
    for (UIGestureRecognizer *gestureRecognizer in self.gestureRecognizers) {
        [self removeGestureRecognizer:gestureRecognizer];
    }
    
    [UIView animateWithDuration:0.5f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         self.containerView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         self.containerView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }
     ];
}

- (IBAction)actionButtonClicked:(id)sender {
    self.onButtonTouchUpInside();
    [self hide];
}

@end
