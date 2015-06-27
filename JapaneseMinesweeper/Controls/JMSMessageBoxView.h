//
//  JMSMessageBoxView.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/24/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMSMessageBoxView : UIView

@property (nonatomic, strong) UIView *dialogView;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic) BOOL useMotionEffects;

@property (nonatomic, strong) void (^onButtonTouchUpInside)(void);

- (instancetype)initWithButtonTitle:(NSString *)title actionHandler:(void (^)(void))onButtonTouchUpInsideHandler;
- (void)show;
- (void)close;

@end
