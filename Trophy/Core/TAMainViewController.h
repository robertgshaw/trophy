//
//  TAMainViewController.h
//  Trophy
//
//  Created by Gigster on 1/2/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TAPresentedViewControllerDelegate <NSObject>

- (void)presentSettings:(UIViewController *)viewController;
- (void)presentProfile:(UIViewController *)viewController;

@end

@interface TAMainViewController : UITabBarController

@end
