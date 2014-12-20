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
#import "UIImage+ImageEffects.h"

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
    [super viewDidAppear:animated];
    
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
    [self.scoreView drawGradientWithStartColor:[UIColor colorFromInteger:0xffe7e7e7]
                                andFinishColor:[UIColor colorFromInteger:0xfff0f0f0]];
    [self.markedMinesCountView drawGradientWithStartColor:[UIColor colorFromInteger:0xffe7e7e7]
                                           andFinishColor:[UIColor colorFromInteger:0xfff0f0f0]];
    [self.cellsCountView drawGradientWithStartColor:[UIColor colorFromInteger:0xffe7e7e7]
                                     andFinishColor:[UIColor colorFromInteger:0xfff0f0f0]];
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
    
    NSString *stringToDisplay = [NSString stringWithFormat:@"%ld/%ld", (long)cellsMarked, (long)minesCount];
    NSUInteger len = [@(cellsMarked) stringValue].length;
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:stringToDisplay];
    
    UIColor *cellsMarkedColor = cellsMarked > minesCount ? [UIColor colorFromInteger:0xffff7f7f] : [UIColor darkGrayColor];
    [string addAttribute:NSForegroundColorAttributeName value:cellsMarkedColor range:NSMakeRange(0, len)];

    self.lbCellsMarked.attributedText = string;
}

-(UIImage *)blurredSnapshot
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.view drawViewHierarchyInRect:self.view.frame afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
    UIGraphicsEndImageContext();
    return blurredSnapshotImage;
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
        /*
        UIImageView *iv = [[UIImageView alloc] initWithFrame:self.view.frame];
        iv.image = [self blurredSnapshot];
        [self.view addSubview:iv];
        [self.view bringSubviewToFront:iv];
         */
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
    NSLog(@"%s", __FUNCTION__);
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
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
