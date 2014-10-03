//
//  MineGridView.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/13/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Structs.h"
#import "Enums.h"

@interface MineGridView : UIView

- (instancetype) initWithFrame:(CGRect)frame;
- (void) fillWithMines: (CGFloat)coverageRate exceptPosition:(struct JMSPosition)position;
- (struct JMSPosition)cellPositionWithCoordinateInside: (CGPoint)point;
- (BOOL) clickedWithCoordinate: (CGPoint)point;
- (void) longTappedWithCoordinate: (CGPoint)point;
- (NSInteger) cellsLeftToOpen;
- (CGFloat) bonus: (struct JMSPosition)position;
- (MineGridCellState) cellState: (struct JMSPosition)position;

@end
