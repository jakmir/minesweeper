//
//  ViewController.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/12/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "ViewController.h"

#import "GameBoardViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
        GameBoardViewController *destinationController = (GameBoardViewController *)segue.destinationViewController;
        destinationController.coverageRate = (self.slider.value / 100);
    }
}
@end
