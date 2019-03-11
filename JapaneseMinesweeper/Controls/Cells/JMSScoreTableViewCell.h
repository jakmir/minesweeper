//
//  JMSScoreTableViewCell.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/16/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JMSGameSessionModel;

@interface JMSScoreTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbScore;
@property (weak, nonatomic) IBOutlet UILabel *lbProgress;
@property (weak, nonatomic) IBOutlet UILabel *lbLevel;

- (void)fillWithModel:(JMSGameSessionModel *)model;

@end
