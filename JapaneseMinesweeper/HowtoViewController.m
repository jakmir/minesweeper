//
//  HowtoViewController.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 2/18/15.
//  Copyright (c) 2015 Jakmir. All rights reserved.
//

#import "HowtoViewController.h"
#import "UIColor+ColorFromHexString.h"
@interface HowtoViewController ()

@end

@implementation HowtoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.mineView drawGradientWithStartColor:[UIColor colorFromInteger:0xffff3300]
                               andFinishColor:[UIColor colorFromInteger:0xffff6600]];
    
    self.mineView.transform = CGAffineTransformScale(self.mineView.transform, 0.5, 0.5);
    /*
    UIImage *img = [self captureView];
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);*/
}

- (UIImage *)captureView {
    
    //hide controls if needed
    CGRect rect = [self.mineView frame];
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.mineView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
