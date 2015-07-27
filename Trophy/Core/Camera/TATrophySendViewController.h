//
//  TATrophySendViewController.h
//  Trophy
//
//  Created by Gigster on 1/8/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TAUser.h"

@protocol TATrophySendViewControllerDelegate <NSObject>

- (void)trophySendViewControllerDidPressClose;
- (void)trophySendViewControllerDidPressSend:(TAUser *)selectedUser;
@end

@interface TATrophySendViewController : UIViewController

@property (nonatomic, weak) id<TATrophySendViewControllerDelegate> delegate;

@end
