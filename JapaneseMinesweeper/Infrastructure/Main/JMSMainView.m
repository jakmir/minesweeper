//
//  JMSMainView.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/2/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import "JMSMainView.h"

@implementation JMSMainView

- (void)awakeFromNib {
    [super awakeFromNib];

    UIImage *wallpaperImage = [UIImage imageNamed:@"wallpaper"];
    self.backgroundColor = [UIColor colorWithPatternImage:wallpaperImage];
    [self drawGradients];
}

- (void)updateButtonsWithModel:(id)gameModel {
    NSString *title = gameModel != nil ? NSLocalizedString(@"Continue", @"Continue") : NSLocalizedString(@"New game", @"New game");
    [self.btnStart setTitle:title forState:UIControlStateNormal];
}

- (void)drawGradients {
    for (JMSGradientButton *gradientButton in self.gradientButtons) {
        [gradientButton drawGradientWithStartColor:[UIColor gradientStartColor]
                                       finishColor:[UIColor gradientFinishColor]];
        [gradientButton.layer setCornerRadius:[[JMSKeyValueSettingsHelper instance] menuButtonCornerRadius]];
        [gradientButton.layer setMasksToBounds:YES];

    }
}

@end
