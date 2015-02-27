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
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowOffset = CGSizeZero;
    self.view.layer.shadowRadius = 6;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds cornerRadius:0].CGPath;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
