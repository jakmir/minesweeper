//
//  UIView+MakeFitToEdges.m
//  JapaneseMinesweeper
//
//  Created by Denis on 6/9/19.
//  Copyright © 2019 Jakmir. All rights reserved.
//

#import "UIView+MakeFitToEdges.h"

@implementation UIView (MakeFitToEdges)

- (void)makeFitToEdges:(UIView *)subView {
    [self makeFitToEdges:subView edgeInsets:UIEdgeInsetsZero];
}

- (void)makeFitToEdges:(UIView *)subView edgeInsets:(UIEdgeInsets)edgeInsets {
    if (subView == nil) {
        return;
    }
    
    [self addSubview:subView];
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = @{@"subview": subView};
    
    NSString *horizontalFormat = [NSString stringWithFormat:@"H:|-(%0.2f)-[subview]-(%0.2f)-|", edgeInsets.left, edgeInsets.right];
    NSString *verticalFormat = [NSString stringWithFormat:@"V:|-(%0.2f)-[subview]-(%0.2f)-|", edgeInsets.top, edgeInsets.bottom];
    NSArray *horizontal = [NSLayoutConstraint constraintsWithVisualFormat:horizontalFormat
                                                                             options:0 metrics:nil
                                                                               views:views];
    NSArray *vertical = [NSLayoutConstraint constraintsWithVisualFormat:verticalFormat
                                                                             options:0 metrics:nil
                                                                               views:views];
    [NSLayoutConstraint activateConstraints:[horizontal arrayByAddingObjectsFromArray:vertical]];
}
@end
