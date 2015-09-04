//
//  TATutorialViewController.h
//  Trophy
//
//  Created by Robert Shaw on 9/1/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  TATutorialViewController;

@protocol TATutorialViewControllerDelegate <NSObject>

@end

@interface TATutorialViewController : UIViewController

@property (nonatomic, weak) id<TATutorialViewControllerDelegate> delegate;

@end
