//
//  TAGroupInviteViewController.h
//  Trophy
//
//  Created by Gigster on 1/25/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAGroupInviteViewController;

@protocol TAGroupInviteViewControllerDelegate <NSObject>

- (void)groupInviteViewControllerDidPressDone:(TAGroupInviteViewController *)groupInviteViewController;

@end

@interface TAGroupInviteViewController : UIViewController

@property (nonatomic, weak) id<TAGroupInviteViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *inviteCode;

@end
