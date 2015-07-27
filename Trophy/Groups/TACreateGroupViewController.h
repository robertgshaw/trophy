//
//  TACreateGroupViewController.h
//  Trophy
//
//  Created by Gigster on 1/24/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TACreateGroupViewController;

@protocol TACreateGroupViewControllerDelegate <NSObject>

- (void)createGroupViewControllerDidCreateGroup:(TACreateGroupViewController *)createGroupViewController;

@end

@interface TACreateGroupViewController : UIViewController

@property (nonatomic, weak) id<TACreateGroupViewControllerDelegate> delegate;

@end
