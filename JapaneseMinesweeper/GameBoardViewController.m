//
//  GameBoardViewController.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "GameBoardViewController.h"

@interface GameBoardViewController ()
{
    BOOL initialTapPerformed;
}

@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger cellsLeftCount;

@end

const CGFloat baseScore = 100;

@implementation GameBoardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    initialTapPerformed = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.score = 0;
    self.cellsLeftCount = (NSInteger)((1 - self.coverageRate) * 100);
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.mineGridView addGestureRecognizer:tapRecognizer];
    
    UILongPressGestureRecognizer *longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    longTapRecognizer.minimumPressDuration = 0.5f;
    [self.mineGridView addGestureRecognizer:longTapRecognizer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.mineGridView.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIGestureRecognizer *gr = obj;
        [self.mineGridView removeGestureRecognizer:gr];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - synchronize labels with real values

- (void) setScore:(NSInteger)score
{
    _score = score;
    [self.lbScore setText:[@(score) stringValue]];
}

- (void) setCellsLeftCount:(NSInteger)cellsLeftCount
{
    _cellsLeftCount = cellsLeftCount;
    [self.lbCellsLeft setText:[@(cellsLeftCount) stringValue]];
}

- (void) singleTap: (UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    
    CGPoint coord = [gestureRecognizer locationInView:self.mineGridView];
    
    struct JMSPosition position = [self.mineGridView cellPositionWithCoordinateInside:coord];
    if (!initialTapPerformed)
    {
        [self.mineGridView fillWithMines:self.coverageRate exceptPosition:position];
        initialTapPerformed = YES;
    }
    
    MineGridCellState oldState = [self.mineGridView cellState:position];
    BOOL mine = [self.mineGridView clickedWithCoordinate:coord];
    MineGridCellState newState = [self.mineGridView cellState:position];
    
    if (mine)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Oops" delegate:self
                                                      cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        self.cellsLeftCount = [self.mineGridView cellsLeftToOpen];
        
        //just opened the cell, not possible to do that twice.
        if (oldState != MineGridCellStateOpened && newState == MineGridCellStateOpened)
        {
            self.score += baseScore * (1 + [self.mineGridView bonus:position]);
        }
        if (self.cellsLeftCount == 0)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:@"You won this round" delegate:self
                                                      cancelButtonTitle:@"Play again" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (void) longTap: (UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"%s", __FUNCTION__);
    
        [self.mineGridView longTappedWithCoordinate:[gestureRecognizer locationInView:self.mineGridView]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
