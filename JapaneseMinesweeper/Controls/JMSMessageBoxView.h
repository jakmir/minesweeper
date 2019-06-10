//
//  JMSMessageBoxView.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/24/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMSMessageBoxView : UIView

@property (nonatomic, strong) void (^onButtonTouchUpInside)(void);

- (void)show;
- (void)hide;

@end
