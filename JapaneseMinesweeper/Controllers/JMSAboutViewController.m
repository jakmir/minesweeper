//
//  JMSAboutViewController.m
//  JapaneseMinesweeper
//
//  Created by Denys Melnyk on 2/26/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "JMSAboutViewController.h"

@interface JMSAboutViewController ()

@end

@implementation JMSAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"xv"]];

    CALayer *layer = self.view.layer;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.5;
    layer.shadowOffset = CGSizeZero;
    layer.shadowRadius = 6;
    layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds cornerRadius:0].CGPath;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isInScreen
{
    CGRect intersection = CGRectIntersection([[UIScreen mainScreen] bounds], self.view.frame);
    return !CGSizeEqualToSize(intersection.size, CGSizeZero);

}

@end
