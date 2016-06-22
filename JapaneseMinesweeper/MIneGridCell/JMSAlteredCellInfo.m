//
//  JMSAlteredCellInfo.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 5/20/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import "JMSAlteredCellInfo.h"

@implementation JMSAlteredCellInfo

- (instancetype)initWithCellInfo:(JMSMineGridCellInfo *)cellInfo col:(NSUInteger)col row:(NSUInteger)row
{
    if (self = [super init])
    {
        JMSPosition position = {.column = col, .row = row};
        _position = position;
        _cellInfo = cellInfo;
    }
    return self;
}
@end
