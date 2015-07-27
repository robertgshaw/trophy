//
//  TAOnboardingViewController.h
//  Trophy
//
//  Created by Robert Shaw on 7/23/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAJoinGroupViewController.h"

@protocol TAPresentSettingsViewControllerDelegate <NSObject>

- (void)presentSettings:(UIViewController *)viewController;

@end

@interface TAOnboardingViewController : UIViewController <TAJoinGroupViewControllerDelegate>

@property (nonatomic, weak) id<TAPresentSettingsViewControllerDelegate>presentSettingsDelegate;

@end