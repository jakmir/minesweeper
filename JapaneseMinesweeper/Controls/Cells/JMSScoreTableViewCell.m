//
//  JMSScoreTableViewCell.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/16/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSScoreTableViewCell.h"
#import "JMSGameSession.h"

@implementation JMSScoreTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)fillWithScore:(NSUInteger)score progress:(NSUInteger)progress level:(NSUInteger)level
{
    self.lbScore.text = [NSString stringWithFormat:@"%lu", (unsigned long)score];
    self.lbLevel.text = [NSString stringWithFormat:@"%lu", (unsigned long)level];
    self.lbProgress.text = [NSString stringWithFormat:@"%lu%%", (unsigned long)progress];
    self.lbProgress.textColor = progress == 100 ? [UIColor completedPercentageLabelColor] : [UIColor progressPercentageLabelColor];
}

- (void)fillWithModel:(JMSGameSession *)model
{
    [self fillWithScore:[model.score unsignedIntegerValue]
               progress:lroundf(model.progress.floatValue)
                  level:[model.level unsignedIntegerValue]];
}
@end
