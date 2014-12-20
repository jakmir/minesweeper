//
//  UIView+Blur.m
//  JapaneseMinesweeper
//
//  Created by Jakmir on 12/19/14.
//  Copyright (c) 2014 Jakmir. All rights reserved.
//

#import "UIView+Blur.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ImageEffects.h"

@implementation UIView (Blur)

-(UIImage *)blurredSnapshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.window.screen.scale);
    [self drawViewHierarchyInRect:self.frame afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage = [snapshotImage applyLightEffect];
    UIGraphicsEndImageContext();

    return blurredSnapshotImage;
}
@end
