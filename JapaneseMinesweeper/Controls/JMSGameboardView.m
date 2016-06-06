//
//  JMSGameboardView.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 5/18/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import "JMSGameboardView.h"
#import "UIColor+ColorFromHexString.h"

static const UInt32 kTooManyMarkedMinesColor = 0xffff7f7f;

@implementation JMSGameboardView

- (void)fillWithModel:(JMSGameModel *)model
{
    [self.lbScore setText:[@(lroundf(model.score)) stringValue]];

    [self.lbProgress setText:[NSString stringWithFormat:@"%ld%%", lroundf(model.progress)]];

    NSString *stringToDisplay = [NSString stringWithFormat:@"%ld/%ld", (long)model.markedCellsCount, (long)model.minesCount];
    NSUInteger len = [@(model.markedCellsCount) stringValue].length;
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:stringToDisplay];
    
    UIColor *cellsMarkedColor = model.markedCellsCount > model.minesCount
                                    ? [UIColor colorFromInteger:kTooManyMarkedMinesColor]
                                    : [UIColor darkGrayColor];
    [string addAttribute:NSForegroundColorAttributeName value:cellsMarkedColor range:NSMakeRange(0, len)];
    self.lbCellsMarked.attributedText = string;
}

- (UIImage *)mineGridViewSnapshot
{
    CGRect bounds = self.mineGridView.bounds;
    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 0);
    [self.mineGridView drawViewHierarchyInRect:bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)updateMenuWithFinishedTutorial:(BOOL)tutorialFinished gameFinished:(BOOL)gameFinished
{
    NSString *caption;
    UIColor *captionColor;
    
    if (gameFinished)
    {
        captionColor = [UIColor brightOrangeColor];
        caption = NSLocalizedString(@"Play again", @"Play again - button caption");
    }
    else
    {
        captionColor = [UIColor brightPurpleColor];
        caption = NSLocalizedString(@"Reset game", @"Reset game - button caption");
    }
    
    [self.btnResetGame setTitleColor:captionColor forState:UIControlStateNormal];
    [self.btnResetGame setTitle:caption forState:UIControlStateNormal];
    [self.btnResetGame setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    CGFloat cornerRadius = [[JMSKeyValueSettingsHelper instance] buttonCornerRadius];
    [self.btnMainMenu.layer setCornerRadius:cornerRadius];
    [self.btnResetGame.layer setCornerRadius:cornerRadius];
    [self.btnMainMenu.layer setMasksToBounds:YES];
    [self.btnResetGame.layer setMasksToBounds:YES];
    
    [self.btnResetGame setEnabled:tutorialFinished];
}
@end
