//
//  JMSMainView.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/2/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import "JMSMainView.h"

@implementation JMSMainView

- (void)updateButtonsWithModel:(id)gameModel
{
    NSString *title = gameModel != nil ? NSLocalizedString(@"Continue", @"Continue") : NSLocalizedString(@"New game", @"New game");
    [self.btnStart setTitle:title forState:UIControlStateNormal];
    
    CGFloat heightSum = 0;
    for (JMSGradientButton *gradientButton in [self gradientButtons])
    {
        heightSum += CGRectGetHeight(gradientButton.frame);
    }
    CGSize size = self.buttonListContainer.frame.size;
    CGFloat interval = (size.height - heightSum) / ([self gradientButtons].count - 1);
    
    CGFloat y = 0;
    for (JMSGradientButton *gradientButton in [self gradientButtons])
    {
        gradientButton.center = CGPointMake(size.width / 2, y + CGRectGetHeight(gradientButton.frame) / 2);
        y += CGRectGetHeight(gradientButton.frame) + interval;
    }
}

- (void)drawGradients
{
    for (JMSGradientButton *gradientButton in self.gradientButtons)
    {
        [gradientButton drawGradientWithStartColor:[UIColor gradientStartColor]
                                    andFinishColor:[UIColor gradientFinishColor]];
        [gradientButton.layer setCornerRadius:[[JMSKeyValueSettingsHelper instance] menuButtonCornerRadius]];
        [gradientButton.layer setMasksToBounds:YES];
    }
}
@end
