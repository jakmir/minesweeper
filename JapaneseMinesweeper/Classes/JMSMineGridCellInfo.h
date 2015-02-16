//
//  JMSMineGridCellInfo.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/14/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enums.h"
#import "Structs.h"

@interface JMSMineGridCellInfo : NSObject

@property (nonatomic) JMSMineGridCellState state;
@property (nonatomic) BOOL mine;
@property (nonatomic) struct JMSMineGridCellNeighboursSummary cellInfo;

@end
