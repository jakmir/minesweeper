//
//  ViewController.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/12/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "MainViewController.h"
#import "GameBoardViewController.h"
#import "UIColor+ColorFromHexString.h"
@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    NSArray *gradientButtons = @[self.btnStart, self.btnLeaderboard, self.btnComplexityLevel];
    for (GradientButton *gradientButton in gradientButtons)
    {
        [gradientButton drawGradientWithStartColor:[UIColor colorFromInteger:0xff00cfff]
                                    andFinishColor:[UIColor colorFromInteger:0xff007fff]];
        [gradientButton.layer setCornerRadius:16];
        [gradientButton.layer setMasksToBounds:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (IBAction)minesQuantityChanged:(UISlider *)sender {
}

- (IBAction)startGame {
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toGame"])
    {
        NSInteger level = [[NSUserDefaults standardUserDefaults] integerForKey:@"level"];
        GameBoardViewController *destinationController = (GameBoardViewController *)segue.destinationViewController;
        destinationController.coverageRate = (level == 0 ?  25 : level) / 100.0;
    }
}
@end
