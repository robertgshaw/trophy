//
//  TARootViewController.h
//  Trophy
//
//  Created by Gigster on 12/10/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TAAppSessionManagerDelegate <NSObject>
@required
- (void)transitionToViewController:(UIViewController *)viewController
                          animated:(BOOL)animated
                    withCompletion:( void (^)(void) )completion;
@end

@interface TARootViewController : UIViewController

@property (nonatomic, strong) UIViewController *activeViewController;

@end
