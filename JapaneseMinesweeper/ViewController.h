//
//  ViewController.h
//  JapaneseMinesweeper
//
//  Created by Jakmir on 9/12/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISlider *slider;

- (IBAction)minesQuantityChanged:(UISlider *)sender;
- (IBAction)startGame;

@end

