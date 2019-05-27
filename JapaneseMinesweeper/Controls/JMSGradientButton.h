//
//  GradientButton.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 10/6/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMSGradientButton : UIButton

- (void)drawGradientWithStartColor:(UIColor *)startColor finishColor:(UIColor *)finishColor;

@end
