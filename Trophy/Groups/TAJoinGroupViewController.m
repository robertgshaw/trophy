//
//  TAJoinGroupViewController.m
//  Trophy
//
//  Created by Gigster on 1/30/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAJoinGroupViewController.h"

#import "TAActiveUserManager.h"
#import "TAJoinGroupView.h"
#import "TAGroupManager.h"

#import "UIColor+TAAdditions.h"
#import <SVProgressHUD.h>

@interface TAJoinGroupViewController () <TAJoinGroupViewDelegate>

@property (nonatomic, strong) TAJoinGroupView *joinGroupView;

@end

@implementation TAJoinGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"Join Group";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Join" style:UIBarButtonItemStyleDone target:self action:@selector(joinButtonPressed)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.joinGroupView = [[TAJoinGroupView alloc] initWithFrame:self.view.bounds];
    self.joinGroupView.delegate = self;
    [self.view addSubview:self.joinGroupView];
}

- (void)joinButtonPressed
{
    NSLog(@"doing this");
    // adds user to group via invite
    [[TAGroupManager sharedManager] addUserToGroupWithInviteCode:self.joinGroupView.inviteCode success:^(TAGroup *group) {
                                                    [self.delegate joinGroupViewControllerDidJoinGroup:self];
                                                    [self sendGroupAlertNotification:group];
                                                } failure:^(NSString *error) {
                                                    [SVProgressHUD showErrorWithStatus:error maskType:SVProgressHUDMaskTypeBlack];
                                                }];

}

- (void)sendGroupAlertNotification:(TAGroup *)group
{
    TAUser *currentUser = [TAActiveUserManager sharedManager].activeUser;
    NSString *currentGroup = group.groupId;
    NSString *message = [NSString stringWithFormat:@"%@ just joined %@", currentUser.name, group.name];
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:currentGroup];
    [push setMessage:message];
    [push sendPushInBackground];
}

#pragma mark - TAJoinGroupViewDelegate Methods

- (void)joinGroupViewDidFinishEnteringInformation:(TAJoinGroupView *)joinGroupView
{
    [self joinButtonPressed];
}

- (void)joinGroupViewShouldShowJoinButton:(TAJoinGroupView *)joinGroupView enabled:(BOOL)enabled
{
    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

@end
