//
//  MineGridView.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "JMSMineGridView.h"
#import "JMSMineGridCell.h"
#import "UIColor+ColorFromHexString.h"
#import "Classes/JMSMineGridCellInfo.h"
#import "Classes/JMSGameSessionInfo.h"

const NSInteger count = 10;
const NSInteger padding = 19;
const NSInteger spacing = 1;

@implementation JMSMineGridView
{
    CALayer *layer;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self prepareCells];
        [self prepareBackground];
    }
    return self;
}

- (void)refreshCells
{
    NSLog(@"%s", __FUNCTION__);
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    for (int col = 0; col < count; col++)
    {
        for (int row = 0; row < count; row++)
        {
            JMSMineGridCell *cell = self.gameboard.map[col][row];
            if (cell.state != MineGridCellStateClosed)
            {
                [cell setNeedsDisplay];
            }
        }
    }
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
}

- (void)refreshAllCells
{
    NSLog(@"%s", __FUNCTION__);
    
    for (int col = 0; col < count; col++)
    {
        for (int row = 0; row < count; row++)
        {
            JMSMineGridCell *cell = self.gameboard.map[col][row];
            if (cell.state != MineGridCellStateOpened)
            {
                [cell setNeedsDisplay];
            }
        }
    }
}

- (NSInteger)markMines
{
    return [self.gameboard markMines];
}

- (void) resetGame
{
    for (int col = 0; col < count; col ++)
    {
        for (int row = 0; row < count; row++)
        {
            JMSMineGridCell *cell = self.gameboard.map[col][row];
            cell.mine = NO;
            cell.state = MineGridCellStateClosed;
            
        }
    }
    _gameFinished = NO;
    [self refreshAllCells];
}

- (void) prepareBackground
{
    self.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:0 green:0.3 blue:0.6 alpha:1];
}

- (void) prepareCells
{
    NSMutableArray *columns = [NSMutableArray array];
    
    NSInteger dimensionSize = (self.frame.size.width - 2 * padding - (count - 1) * spacing) / count;
    CGSize size = CGSizeMake(dimensionSize, dimensionSize);
    CGVector offset = CGVectorMake(padding, padding);
    for (int col = 0; col < count; col++)
    {
        NSMutableArray *line = [NSMutableArray array];
        for (int row = 0; row < count; row++)
        {
            CGRect frame = CGRectMake((size.width + spacing) * col + offset.dx,
                                      (size.height + spacing) * row + offset.dy,
                                      size.width,
                                      size.height);
            JMSMineGridCell *mineGridCell = [[JMSMineGridCell alloc] initWithFrame:frame];
            mineGridCell.mineGridView = self;
            [line addObject:mineGridCell];
            
            [self addSubview:mineGridCell];
        }
        [columns addObject:line];
    }
    
    _gameboard = [[JMSMineGrid alloc] init];
    _gameboard.map = columns;
}

- (void) fillMapWithLevel:(NSUInteger)level exceptPosition:(struct JMSPosition)position
{
    [self.gameboard fillMapWithLevel:level exceptPosition:position];
}

- (CGFloat)bonus:(struct JMSPosition)position
{
    return [self.gameboard bonus:position];
}

- (NSInteger) cellsCount
{
    return self.gameboard.rowCount * self.gameboard.colCount;
}

- (NSInteger) cellsLeftToOpen
{
    return self.gameboard.cellsLeftToOpen;
}

- (JMSMineGridCell *)cellWithCoordinateInside: (CGPoint)point
{
    JMSMineGridCell *cell = nil;
    struct JMSPosition position = [self cellPositionWithCoordinateInside:point];
    if (position.row != NSNotFound && position.column != NSNotFound)
    {
        cell = self.gameboard.map[position.column][position.row];
    }
    
    return cell;
}

- (struct JMSPosition)cellPositionWithCoordinateInside: (CGPoint)point
{
    CGVector offset = CGVectorMake(padding, padding);
    NSInteger dimensionSize = (self.frame.size.width - 2 * padding - (count - 1) * spacing) / count;
    CGPoint relativePoint = CGPointMake(point.x - offset.dx, point.y - offset.dy);
    int col = (int)relativePoint.x / (dimensionSize + spacing);
    int row = (int)relativePoint.y / (dimensionSize + spacing);
    BOOL clickedInField = CGRectContainsPoint(CGRectMake(0, 0, (dimensionSize + spacing) * count, (dimensionSize + spacing) * count), relativePoint);
    BOOL clickedInCell = (int)relativePoint.x % (dimensionSize + spacing) < dimensionSize &&
    (int)relativePoint.y % (dimensionSize + spacing) < dimensionSize;
    
    struct JMSPosition position;
    position.row = NSNotFound;
    position.column = NSNotFound;
    
    if (clickedInField && clickedInCell)
    {
        position.row = row;
        position.column = col;
    }
    
    return position;
}


- (JMSMineGridCellState) cellState:(struct JMSPosition)position
{
    return [self.gameboard cellState:position];
}

- (BOOL) clickedWithCoordinate: (CGPoint)point
{
    if (self.gameFinished) return NO;
    
    JMSMineGridCell *cell = [self cellWithCoordinateInside:point];
    
    if (cell)
    {
        [cell setState:MineGridCellStateOpened];
        return cell.mine;
    }
    
    return NO;
}

- (void) finalizeGame
{
    _gameFinished = YES;
    [self refreshAllCells];
}

- (NSUInteger) markUncoveredMines
{
    NSUInteger count = 0;
    for (NSArray *column in self.gameboard.map)
    {
        for (JMSMineGridCell *cell in column)
        {
            if (cell.mine && cell.state == MineGridCellStateClosed)
            {
                [cell setState:MineGridCellStateMarked];
                count++;
            }
        }
    }
    return count;
}

- (void) longTappedWithCoordinate:(CGPoint)point
{
    if (self.gameFinished) return;
    
    JMSMineGridCell *cell = [self cellWithCoordinateInside:point];
    
    if (cell)
    {
        switch (cell.state)
        {
            case MineGridCellStateMarked:
                [cell setState:MineGridCellStateClosed];
                break;
            case MineGridCellStateClosed:
                [cell setState:MineGridCellStateMarked];
                break;
            default:
                break;
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    NSLog(@"%s", __FUNCTION__);
    
    [super drawRect:rect];
}

#pragma mark - Export/Import methods

- (NSArray *)exportMap
{
    NSMutableArray *localMap = [NSMutableArray array];
    for (NSArray *vector in self.gameboard.map)
    {
        NSMutableArray *localVector = [NSMutableArray array];
        for (JMSMineGridCell *cell in vector)
        {
            [localVector addObject:cell.exportCell];
        }
        [localMap addObject:localVector];
    }
    return localMap;
}

- (void)importMap:(NSArray *)gameboardMap
{
    NSLog(@"%s", __FUNCTION__);
    
    for (int col = 0; col < count; col++)
    {
        for (int row = 0; row < count; row++)
        {
            JMSMineGridCell *cell = self.gameboard.map[col][row];
            JMSMineGridCellInfo *cellInfo = gameboardMap[col][row];
            [cell import:cellInfo];
        }
    }
}

@end
