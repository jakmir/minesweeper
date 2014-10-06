//
//  GameBoardViewController.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "GameBoardViewController.h"
#import "MineGridCell.h"
#import "UIColor+ColorFromHexString.h"

@interface GameBoardViewController ()
{
    BOOL initialTapPerformed;
    NSInteger minesCount;
}

@property (nonatomic) CGFloat score;
@property (nonatomic) NSInteger cellsLeftCount;
@property (nonatomic) NSInteger cellsMarked;

@end

const CGFloat baseScore = 175;

@implementation GameBoardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    initialTapPerformed = NO;
}

- (void)addGestureRecognizers
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.mineGridView addGestureRecognizer:tapRecognizer];
    
    UILongPressGestureRecognizer *longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    longTapRecognizer.minimumPressDuration = 0.5f;
    [self.mineGridView addGestureRecognizer:longTapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.score = 0;
    self.cellsLeftCount = (NSInteger)((1 - self.coverageRate) * 100);
    minesCount = [self.mineGridView cellsCount] - self.cellsLeftCount;
    self.cellsMarked = 0;
    
    [self addGestureRecognizers];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self drawGradients];
}

- (void)removeGestureRecognizers
{
    [self.mineGridView.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIGestureRecognizer *gr = obj;
        [self.mineGridView removeGestureRecognizer:gr];
    }];
}

- (void) drawGradients
{
    [self.scoreView drawGradientWithStartColor:[UIColor colorFromInteger:0xffff9500]
                                andFinishColor:[UIColor colorFromInteger:0xfff75e3a]];
    [self.markedMinesCountView drawGradientWithStartColor:[UIColor colorFromInteger:0xffc644fc]
                                           andFinishColor:[UIColor colorFromInteger:0xff5856d6]];
    [self.cellsCountView drawGradientWithStartColor:[UIColor colorFromInteger:0xff1d77ef]
                                     andFinishColor:[UIColor colorFromInteger:0xff83f3fd]];
    [self.btnMainMenu drawGradientWithStartColor:[UIColor colorFromInteger:0x1fcfcfcf] andFinishColor:[UIColor colorFromInteger:0x1fbfbfbf]];
    [self.btnLeaderboards drawGradientWithStartColor:[UIColor colorFromInteger:0x1fcfcfcf] andFinishColor:[UIColor colorFromInteger:0x1fbfbfbf]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeGestureRecognizers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

#pragma mark - synchronize labels with real values

- (void) setScore:(CGFloat)score
{
    _score = score;
    [self.lbScore setText:[@((NSInteger)score) stringValue]];
}

- (void) setCellsLeftCount:(NSInteger)cellsLeftCount
{
    _cellsLeftCount = cellsLeftCount;
    [self.lbCellsLeft setText:[@(cellsLeftCount) stringValue]];
}

- (void) setCellsMarked:(NSInteger)cellsMarked
{
    _cellsMarked = cellsMarked;
    
    NSString *stringToDisplay = [NSString stringWithFormat:@"%d/%d", cellsMarked, minesCount];
    NSUInteger len = [@(cellsMarked) stringValue].length;
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:stringToDisplay];
    
    UIColor *cellsMarkedColor = cellsMarked > minesCount ? [UIColor colorFromInteger:0xffff7f7f] : [UIColor whiteColor];
    [string addAttribute:NSForegroundColorAttributeName value:cellsMarkedColor range:NSMakeRange(0, len)];

    self.lbCellsMarked.attributedText = string;
}

#pragma mark - handle taps

- (void) singleTap: (UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    
    CGPoint coord = [gestureRecognizer locationInView:self.mineGridView];
    
    struct JMSPosition position = [self.mineGridView cellPositionWithCoordinateInside:coord];
    
    if (position.row == NSNotFound || position.column == NSNotFound) return;
    
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
            if (oldState == MineGridCellStateMarked)
            {
                self.cellsMarked--;
            }
            self.score += baseScore * pow(1 + self.coverageRate, 3) * pow(1 + [self.mineGridView bonus:position], 3);
        }
        
        if (self.cellsLeftCount == 0)
        {
            self.score *= (1 + self.coverageRate);
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
        
        CGPoint coord = [gestureRecognizer locationInView:self.mineGridView];
        struct JMSPosition position = [self.mineGridView cellPositionWithCoordinateInside:coord];
        
        if (position.row == NSNotFound || position.column == NSNotFound) return;
        
        MineGridCellState oldState = [self.mineGridView cellState:position];
        [self.mineGridView longTappedWithCoordinate:coord];
        MineGridCellState newState = [self.mineGridView cellState:position];
        
        if (oldState == MineGridCellStateMarked && newState == MineGridCellStateClosed)
        {
            self.cellsMarked--;
        }
        if (oldState == MineGridCellStateClosed && newState == MineGridCellStateMarked)
        {
            self.cellsMarked++;
        }
    }
}

#pragma mark - alerts

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
