//
//  TARootViewController.m
//  Trophy
//
//  Created by Gigster on 12/10/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

@import CoreGraphics;

#import "TARootViewController.h"
#import "SWRevealViewController.h"

#import "TAActiveUserManager.h"
#import "TADefines.h"
#import "TAGroup.h"

#import "TAGroupManager.h"
#import "TATrophyManager.h"

#import <Parse/Parse.h>

@interface TARootViewController () <TAAppSessionManagerDelegate>

@property (nonatomic, strong) UIViewController *nextViewController;

@end

@implementation TARootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [TAActiveUserManager sharedManager].delegate = self;
    
    
    SWRevealViewController *revealController = [self revealViewController];
    
    
    [revealController panGestureRecognizer];
}

#pragma mark - AppSessionManager Delegate Methods

- (void)transitionToViewController:(UIViewController *)viewController
                          animated:(BOOL)animated
                    withCompletion:( void (^)(void) )completion
{
    if (self.nextViewController == nil) {
        [self.activeViewController willMoveToParentViewController:nil];
    } else {
        [self.nextViewController removeFromParentViewController];
        [self.nextViewController.view removeFromSuperview];
    }

    self.nextViewController = viewController;

    [self addChildViewController:viewController];
    viewController.view.alpha = 0.0;
    viewController.view.frame = self.view.bounds;
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:viewController.view];

    BlockWeakSelf weakSelf = self;

    [UIView animateWithDuration:animated ? 0.25 : 0.0
                     animations:^{
                         viewController.view.alpha = 1.0;
                     } completion:^(BOOL finished) {

                         [weakSelf.view bringSubviewToFront:viewController.view];
                         [weakSelf.activeViewController.view removeFromSuperview];

                        if (weakSelf.nextViewController == viewController) {
                             [weakSelf.activeViewController dismissViewControllerAnimated:animated completion:nil];
                             [weakSelf.activeViewController removeFromParentViewController];
                             weakSelf.activeViewController = weakSelf.nextViewController;
                             [weakSelf.nextViewController didMoveToParentViewController:weakSelf];
                             
                             weakSelf.nextViewController = nil;
                             
                             [weakSelf setNeedsStatusBarAppearanceUpdate];
                             
                             if (completion != NULL) {
                                 completion();
                             }
                         }
                     }];
}

@end
