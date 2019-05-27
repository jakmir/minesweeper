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
#import "UIColor+GameColorPalette.h"
#import "JMSMineGridCellInfo.h"
#import "JMSGameModel.h"

const NSInteger count = 10;
const NSInteger padding = 19;
const NSInteger spacing = 1;

@interface JMSMineGridView()

@property (nonatomic, strong) NSMutableArray *highlightedAreas;

@end

@implementation JMSMineGridView
{
    CALayer *layer;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self prepareCells];
        [self prepareBackground];
        self.highlightedAreas = [NSMutableArray array];
    }
    return self;
}

- (void)refreshCells {
    for (int col = 0; col < count; col++) {
        for (int row = 0; row < count; row++) {
            JMSMineGridCell *cell = self.map[col][row];
            if (cell.state != MineGridCellStateClosed) {
                [cell setNeedsDisplay];
            }
        }
    }
}

- (void)refreshAllCells {
    for (int col = 0; col < count; col++) {
        for (int row = 0; row < count; row++) {
            JMSMineGridCell *cell = self.map[col][row];
            if (cell.state != MineGridCellStateOpened) {
                [cell setNeedsDisplay];
            }
        }
    }
}

- (void)resetGame {
    for (int col = 0; col < count; col ++) {
        for (int row = 0; row < count; row++) {
            JMSMineGridCell *cell = self.map[col][row];
            cell.mine = NO;
            cell.state = MineGridCellStateClosed;
        }
    }
    _gameFinished = NO;
    [self refreshAllCells];
}

- (void)prepareBackground {
    self.backgroundColor = [UIColor whiteColor];
}

- (void)prepareCells {
    NSMutableArray *columns = [NSMutableArray array];
    
    NSInteger dimensionSize = (self.frame.size.width - 2 * padding - (count - 1) * spacing) / count;
    CGSize size = CGSizeMake(dimensionSize, dimensionSize);
    CGVector offset = CGVectorMake(padding, padding);
    for (int col = 0; col < count; col++) {
        NSMutableArray *line = [NSMutableArray array];
        for (int row = 0; row < count; row++) {
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
    
    self.map = columns;
}

- (void)refreshCellWithPosition:(JMSPosition)position {
    JMSMineGridCell *cell = self.map[position.column][position.row];
    [cell setNeedsDisplay];
}

- (JMSPosition)cellPositionWithCoordinateInside:(CGPoint)point {
    CGVector offset = CGVectorMake(padding, padding);
    NSInteger dimensionSize = (self.frame.size.width - 2 * padding - (count - 1) * spacing) / count;
    CGPoint relativePoint = CGPointMake(point.x - offset.dx, point.y - offset.dy);
    int col = (int)relativePoint.x / (dimensionSize + spacing);
    int row = (int)relativePoint.y / (dimensionSize + spacing);
    BOOL clickedInField = CGRectContainsPoint(CGRectMake(0, 0, (dimensionSize + spacing) * count, (dimensionSize + spacing) * count),
                                              relativePoint);
    BOOL clickedInCell = (int)relativePoint.x % (dimensionSize + spacing) < dimensionSize &&
                         (int)relativePoint.y % (dimensionSize + spacing) < dimensionSize;
    
    JMSPosition position = {.row = NSNotFound, .column = NSNotFound};
    
    if (clickedInField && clickedInCell)
    {
        position.row = row;
        position.column = col;
    }
    
    return position;
}

- (void) finalizeGame
{
    _gameFinished = YES;
}

- (NSUInteger)markUncoveredMines {
    NSUInteger count = 0;
    for (NSArray *column in self.map) {
        for (JMSMineGridCell *cell in column) {
            if (cell.mine && cell.state == MineGridCellStateClosed) {
                [cell setState:MineGridCellStateMarked];
                count++;
            }
        }
    }
    return count;
}

#pragma mark - Export/Import methods

- (NSArray *)exportMap {
    NSMutableArray *localMap = [NSMutableArray array];
    for (NSArray *vector in self.map) {
        NSMutableArray *localVector = [NSMutableArray array];
        for (JMSMineGridCell *cell in vector) {
            [localVector addObject:cell.exportCell];
        }
        [localMap addObject:localVector];
    }
    return localMap;
}

- (void)importFromGameboardMap:(NSArray *)gameboardMap {
    for (int col = 0; col < count; col++) {
        for (int row = 0; row < count; row++) {
            JMSMineGridCell *cell = self.map[col][row];
            JMSMineGridCellInfo *cellInfo = gameboardMap[col][row];
            [cell importFromCellInfo:cellInfo];
        }
    }
}

#pragma mark - Higlight/Unhighlight methods

- (void)highlightCellWithPosition:(JMSPosition)position {
    JMSMineGridCell *cell = self.map[position.column][position.row];

    CGRect rect = CGRectInset(cell.frame, 1, 1);
    CAShapeLayer *antLayer = [CAShapeLayer layer];
    [antLayer setBounds:rect];
    [antLayer setPosition:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))];
    [antLayer setFillColor:[[UIColor antDashedBorderColor] CGColor]];
    [antLayer setStrokeColor:[[UIColor blueColor] CGColor]];
    [antLayer setLineWidth:1];
    [antLayer setLineJoin:kCALineJoinRound];
    [antLayer setLineDashPattern:@[@10, @4]];
        
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    [antLayer setPath:path];
    CGPathRelease(path);
        
    [self.layer addSublayer:antLayer];
    
    CABasicAnimation *dashAnimation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
        
    [dashAnimation setFromValue:@0];
    [dashAnimation setToValue:@14];
    [dashAnimation setDuration:0.5f];
    [dashAnimation setRepeatCount:10000];
    
    [antLayer addAnimation:dashAnimation forKey:@"linePhase"];
    
    [self.highlightedAreas addObject:antLayer];
}

- (void)removeHighlights {
    [self.highlightedAreas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CAShapeLayer *lyr = obj;
        [lyr removeFromSuperlayer];
    }];
    
    [self.highlightedAreas removeAllObjects];
}

#pragma mark - Model-Dependent Methods that update view and subviews

- (void)updateWithModel:(JMSGameModel *)gameSessionInfo {
    for (int col = 0; col < count; col++) {
        for (int row = 0; row < count; row++)  {
            JMSPosition position = {.column = col, .row = row};
            JMSAlteredCellInfo *alteredCellModel = (JMSAlteredCellInfo *)gameSessionInfo.map[col][row];
            alteredCellModel.position = position;
            [self updateCellWithAlteredCellModel:alteredCellModel];
        }
    }
}

- (void)updateCellWithAlteredCellModel:(JMSAlteredCellInfo *)alteredCellModel {
    NSUInteger col = alteredCellModel.position.column, row = alteredCellModel.position.row;
    JMSMineGridCell *cell = self.map[col][row];
    [cell importFromCellInfo:alteredCellModel.cellInfo];
    [cell setNeedsDisplay];
}

@end
