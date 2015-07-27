//
//  TAJoinGroupViewController.h
//  Trophy
//
//  Created by Gigster on 1/30/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAJoinGroupViewController;

@protocol TAJoinGroupViewControllerDelegate <NSObject>

- (void)joinGroupViewControllerDidJoinGroup:(TAJoinGroupViewController *)joinGroupViewController;

@end

@interface TAJoinGroupViewController : UIViewController

@property (nonatomic, weak) id<TAJoinGroupViewControllerDelegate>delegate;

@end
