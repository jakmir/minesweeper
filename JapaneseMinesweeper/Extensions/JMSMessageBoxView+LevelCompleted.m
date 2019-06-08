//
//  JMSMessageBoxView+LevelCompleted.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 5/22/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import "JMSMessageBoxView+LevelCompleted.h"

@implementation JMSMessageBoxView (LevelCompleted)

+ (UIView *)messageBoxContentView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    
    UILabel *lbCaption = [[UILabel alloc] initWithFrame:CGRectZero];
    UILabel *lbText = [[UILabel alloc] initWithFrame:CGRectZero];
    lbCaption.translatesAutoresizingMaskIntoConstraints = NO;
    lbText.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:lbCaption];
    [contentView addSubview:lbText];
    
    lbCaption.textAlignment = NSTextAlignmentCenter;
    lbCaption.text = NSLocalizedString(@"You won this round", nil);
    lbCaption.font = [UIFont systemFontOfSize:28 weight:UIFontWeightLight];
    lbCaption.textColor = [UIColor juicyOrangeColor];
    [lbCaption addConstraint:[NSLayoutConstraint constraintWithItem:lbCaption
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:0 constant:32]];
    [[lbCaption.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:20] setActive:YES];
    [[lbCaption.leftAnchor constraintEqualToAnchor:contentView.leftAnchor constant:0] setActive:YES];
    [[lbCaption.rightAnchor constraintEqualToAnchor:contentView.rightAnchor constant:0] setActive:YES];
    

    lbText.numberOfLines = 0;
    lbText.textAlignment = NSTextAlignmentCenter;
    lbText.text = NSLocalizedString(@"Congralutations", nil);
    lbText.font = [UIFont systemFontOfSize:17];
    lbText.textColor = [UIColor lightGrayColor];
    [lbText addConstraint:[NSLayoutConstraint constraintWithItem:lbText
                                                       attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:nil
                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                      multiplier:0 constant:96]];
    [[lbText.topAnchor constraintEqualToAnchor:lbCaption.bottomAnchor constant:16] setActive:YES];
    [[lbText.leftAnchor constraintEqualToAnchor:contentView.leftAnchor constant:20] setActive:YES];
    [[lbText.rightAnchor constraintEqualToAnchor:contentView.rightAnchor constant:-20] setActive:YES];

    
    return contentView;
}
@end
