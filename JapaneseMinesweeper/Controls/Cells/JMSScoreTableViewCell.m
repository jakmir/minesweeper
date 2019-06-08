//
//  JMSScoreTableViewCell.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/16/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSScoreTableViewCell.h"
#import "JMSGameSessionModel.h"

@implementation JMSScoreTableViewCell

- (void)fillWithScore:(NSInteger)score progress:(NSInteger)progress level:(NSInteger)level {
    self.lbScore.text = [NSString stringWithFormat:@"%lu", (unsigned long)score];
    self.lbLevel.text = [NSString stringWithFormat:@"%lu", (unsigned long)level];
    self.lbProgress.text = [NSString stringWithFormat:@"%lu%%", (unsigned long)progress];
    self.lbProgress.textColor = progress == 100 ? [UIColor completedPercentageLabelColor] : [UIColor progressPercentageLabelColor];
}

- (void)fillWithModel:(JMSGameSessionModel *)model {
    [self fillWithScore:model.score
               progress:lround(model.progress)
                  level:model.level];
}
@end
