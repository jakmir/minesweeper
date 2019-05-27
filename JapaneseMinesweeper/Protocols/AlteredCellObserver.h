//
//  AlteredCellObserver.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 5/20/16.
//  Copyright © 2016 Jakmir. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AlteredCellObserver <NSObject>

@required
- (void)cellsChanged:(NSArray *)alteredCellsCollection;
- (void)flagAdded;
- (void)flagRemoved;
- (void)ranIntoMine;
- (void)cellSuccessfullyOpened;
- (void)levelCompleted;

@end
