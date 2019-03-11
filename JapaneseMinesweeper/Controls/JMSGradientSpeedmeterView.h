//
//  JMSGradientSpeedmeterView.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/16/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JMSGradientSpeedmeterView;

@protocol JMSGradientSpeedmeterViewDelegate <NSObject>

- (void)didSpeedmeterValueChange:(JMSGradientSpeedmeterView *)sender value:(NSUInteger)value;

@end

@interface JMSGradientSpeedmeterView : UIView

@property (nonatomic, weak) id<JMSGradientSpeedmeterViewDelegate> delegate;

@property (nonatomic) NSUInteger power;
@property (nonatomic) NSUInteger minimumValue;
@property (nonatomic) NSUInteger maximumValue;

@end
