//
//  JMSLeaderboardView.m
//  JapaneseMinesweeper
//
//  Created by Denys Melnyk on 5/28/19.
//  Copyright © 2019 Jakmir. All rights reserved.
//

#import "JMSLeaderboardView.h"

@interface JMSLeaderboardView()

@property (weak, nonatomic) IBOutlet UIButton *btnShowGameCenterScreen;
@property (weak, nonatomic) IBOutlet UIButton *btnBackToMainMenu;
@property (weak, nonatomic) IBOutlet UILabel *lbEmptyRemark;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JMSLeaderboardView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CGFloat cornerRadius = [[JMSKeyValueSettingsHelper instance] buttonCornerRadius];
    [self.btnBackToMainMenu.layer setCornerRadius:cornerRadius];
    [self.btnShowGameCenterScreen.layer setCornerRadius:cornerRadius];
    [self.btnBackToMainMenu.layer setMasksToBounds:YES];
    [self.btnShowGameCenterScreen.layer setMasksToBounds:YES];
}

- (void)fillWithModel:(NSArray *)model {
    self.lbEmptyRemark.hidden = model.count > 0;
    [self.tableView reloadData];
}

@end
