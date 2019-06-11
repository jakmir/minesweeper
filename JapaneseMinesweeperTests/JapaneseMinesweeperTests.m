//
//  JapaneseMinesweeperTests.m
//  JapaneseMinesweeperTests
//
//  Created by Jakmir on 9/12/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "JMSGameModel.h"
#import "JMSMineGridCellInfo.h"

@interface JapaneseMinesweeperTests : XCTestCase

@end

@implementation JapaneseMinesweeperTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        NSUInteger level = 25;
        JMSGameModel *gameModel = [[JMSGameModel alloc] initWithLevel:level];
        JMSPosition position = {.column = 0, .row = 0};
        [gameModel fillMapWithLevel:level exceptPosition:position];
    }];
}


- (void)testGameModelIfMapAssigned {
    NSUInteger level = 25;
    JMSGameModel *gameModel = [[JMSGameModel alloc] initWithLevel:level];
    JMSPosition position = {.column = 0, .row = 0};
    [gameModel fillMapWithLevel:level exceptPosition:position];
    XCTAssertNotNil(gameModel.mapModel.map, @"Map is not assigned");
}

- (void)testGameModelAssignedPositionIsSafeAndClosed {
    NSUInteger level = 25;
    JMSGameModel *gameModel = [[JMSGameModel alloc] initWithLevel:level];
    JMSPosition position = {.column = 0, .row = 0};
    [gameModel fillMapWithLevel:level exceptPosition:position];
    
    XCTAssertTrue(![gameModel.mapModel isMinePresentAtPosition:position] &&
                   [gameModel.mapModel cellState:position] == MineGridCellStateClosed);
}

- (void)testGameModelFirstClickPositionIsSafeAndOpened {
    NSUInteger level = 25;
    JMSGameModel *gameModel = [[JMSGameModel alloc] initWithLevel:level];
    JMSPosition position = {.column = 0, .row = 0};
    [gameModel fillMapWithLevel:level exceptPosition:position];
    [gameModel openCellWithPosition:position];
    
    XCTAssertTrue(![gameModel isMinePresentAtPosition:position] &&
                  [gameModel.mapModel cellState:position] == MineGridCellStateOpened);
}

- (void)testGameModelFirstClickPositionIsSafeAndMarked {
    NSUInteger level = 25;
    JMSGameModel *gameModel = [[JMSGameModel alloc] initWithLevel:level];
    JMSPosition position = {.column = 0, .row = 0};
    [gameModel fillMapWithLevel:level exceptPosition:position];
    [gameModel toggleMarkWithPosition:position];
    
    XCTAssertTrue(![gameModel isMinePresentAtPosition:position] &&
                  [gameModel.mapModel cellState:position] == MineGridCellStateMarked);
}

- (void)testGameModel {
    NSUInteger level = 25;
    
    JMSGameModel *gameModel = [[JMSGameModel alloc] initWithLevel:level];

    JMSPosition position = {.column = 0, .row = 0};
    [gameModel fillMapWithLevel:level exceptPosition:position];
    
    NSUInteger minesCount = 0;
    for (NSUInteger col = 0; col < gameModel.mapModel.map.count; col++) {
        NSArray *vector = gameModel.mapModel.map[col];
        for (NSUInteger row = 0; row < vector.count; row++) {
            JMSMineGridCellInfo *mineGridCellInfo = vector[row];
            if (mineGridCellInfo.mine) {
                minesCount++;
            }
        }
    }
    XCTAssertTrue(level == minesCount);
}
@end
