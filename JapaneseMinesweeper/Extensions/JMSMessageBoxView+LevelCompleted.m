//
//  JMSMessageBoxView+LevelCompleted.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 5/22/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import "JMSMessageBoxView+LevelCompleted.h"

@implementation JMSMessageBoxView (LevelCompleted)

+ (UIView *)messageBoxContentView
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    UILabel *lbCaption = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 32)];
    lbCaption.textAlignment = NSTextAlignmentCenter;
    lbCaption.attributedText = [[NSAttributedString alloc] initWithString:@"You won this round"
                                                               attributes:@{
                                                                            NSForegroundColorAttributeName:
                                                                                [UIColor juicyOrangeColor],
                                                                            NSFontAttributeName:
                                                                                [UIFont systemFontOfSize:28 weight:UIFontWeightLight]
                                                                            }];
    
    UILabel *lbText = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 280, 150)];
    lbText.numberOfLines = 0;
    lbText.textAlignment = NSTextAlignmentCenter;
    
    lbText.attributedText = [[NSAttributedString alloc] initWithString:@"Congratulations!\n\nAll mines were discovered"
                                                            attributes:@{
                                                                         NSForegroundColorAttributeName:
                                                                             [UIColor lightGrayColor],
                                                                         NSFontAttributeName:
                                                                             [UIFont systemFontOfSize:17]
                                                                         }];
    [contentView addSubview:lbCaption];
    [contentView addSubview:lbText];
    
    return contentView;
}
@end
