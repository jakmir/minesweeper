//
//  JMSMainView.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 6/2/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMSGradientButton.h"

@interface JMSMainView : UIView

@property (weak, nonatomic) IBOutlet JMSGradientButton *btnStart;
@property (weak, nonatomic) IBOutlet JMSGradientButton *btnComplexityLevel;
@property (weak, nonatomic) IBOutlet JMSGradientButton *btnLeaderboard;
@property (weak, nonatomic) IBOutlet UIView *buttonListContainer;
@property (weak, nonatomic) IBOutlet UILabel *lbCaption;
@property (strong, nonatomic) IBOutletCollection(JMSGradientButton) NSArray *gradientButtons;

- (void)updateButtonsWithModel:(id)gameModel;
- (void)drawGradients;

@end
