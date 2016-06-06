//
//  JMSAlteredCellInfo.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 5/20/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import "JMSMineGridCellInfo.h"

@interface JMSAlteredCellInfo : NSObject;

@property (nonatomic) JMSPosition position;
@property (nonatomic, strong) JMSMineGridCellInfo *cellInfo;

- (instancetype)initWithCellInfo:(JMSMineGridCellInfo *)cellInfo col:(NSUInteger)col row:(NSUInteger)row;
@end
