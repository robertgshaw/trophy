//
//  TAGroupListViewController.h
//  Trophy
//
//  Created by Gigster on 1/21/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAGroupListViewController;

@protocol TAGroupListViewControllerDelegate <NSObject>

- (void)groupListViewControllerDidReloadGroups:(TAGroupListViewController *)groupListViewController;
- (void)groupListViewControllerDidChangeGroups:(TAGroupListViewController *)groupListViewController;
- (void)groupListViewControllerDidAddGroup:(TAGroupListViewController *)groupListViewController;

@end

@interface TAGroupListViewController : UIViewController

@property (nonatomic, weak) id<TAGroupListViewControllerDelegate> delegate;

- (CGFloat)heightForList;

@end
