//
//  TATrophyCloseupViewController.h
//  Trophy
//
//  Created by Gigster on 1/12/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TATrophy.h"

@class TATrophyCloseupViewController;

@protocol TATrophyCloseupViewControllerDelegate <NSObject>

- (void)trophyCloseupDidPerformAction:(TATrophyCloseupViewController *)viewController;

@end

@interface TATrophyCloseupViewController : UIViewController

- (instancetype)initWithTrophy:(TATrophy *)trophy;

@property (nonatomic, weak) id<TATrophyCloseupViewControllerDelegate> delegate;

@end
