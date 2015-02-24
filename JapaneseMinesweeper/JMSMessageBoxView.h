//
//  JMSMessageBoxView.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/24/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JMSMessageBoxViewDelegate

- (void)messageBoxButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface JMSMessageBoxView : UIView<JMSMessageBoxViewDelegate>

@property (nonatomic, retain) UIView *parentView;
@property (nonatomic, retain) UIView *dialogView;
@property (nonatomic, retain) UIView *containerView;

@property (nonatomic, assign) id<JMSMessageBoxViewDelegate> delegate;
@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;

@property (copy) void (^onButtonTouchUpInside)(JMSMessageBoxView *alertView, int buttonIndex);

- (void)show;
- (void)close;
- (void)setOnButtonTouchUpInside:(void (^)(JMSMessageBoxView *alertView, int buttonIndex))onButtonTouchUpInside;

@end
