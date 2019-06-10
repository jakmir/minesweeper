//
//  UIView+MakeFitToEdges.h
//  JapaneseMinesweeper
//
//  Created by Denis on 6/9/19.
//  Copyright © 2019 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (MakeFitToEdges)

- (void)makeFitToEdges:(UIView *)subView edgeInsets:(UIEdgeInsets)edgeInsets;
- (void)makeFitToEdges:(UIView *)subView;

@end

NS_ASSUME_NONNULL_END
