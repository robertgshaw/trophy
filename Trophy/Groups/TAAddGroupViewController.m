//
//  TAAddGroupViewController.m
//  Trophy
//
//  Created by Gigster on 1/30/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAAddGroupViewController.h"

#import "UIColor+TAAdditions.h"
#import "TAGroupManager.h"

static const CGFloat kGroupButtonWidth = 150.0;
static const CGFloat kGroupButtonHeight = 40.0;

@interface TAAddGroupViewController ()

@end

@implementation TAAddGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIImageView *trophyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    CGRect frame = trophyImageView.frame;
    frame.origin.x = CGRectGetMidX(self.view.bounds) - floorf(CGRectGetWidth(trophyImageView.frame) / 2.0);
    frame.origin.y = 50.0;
    trophyImageView.frame = frame;
    [self.view addSubview:trophyImageView];
    
    UIButton *createGroupButton = [[UIButton alloc] init];
    [createGroupButton setTitle:@"Create Group" forState:UIControlStateNormal];
    [createGroupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    createGroupButton.backgroundColor = [UIColor trophyYellowColor];
    createGroupButton.layer.cornerRadius = 5.0;
    frame = CGRectZero;
    frame.origin.x = floorf((CGRectGetWidth(self.view.bounds) - kGroupButtonWidth) / 2.0);
    frame.origin.y = CGRectGetMaxY(trophyImageView.frame) + 50.0;
    frame.size.width = kGroupButtonWidth;
    frame.size.height = kGroupButtonHeight;
    createGroupButton.frame = frame;
    [createGroupButton addTarget:self action:@selector(createGroupButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createGroupButton];
    
    UIButton *joinGroupButton = [[UIButton alloc] init];
    [joinGroupButton setTitle:@"Join Group" forState:UIControlStateNormal];
    [joinGroupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    joinGroupButton.backgroundColor = [UIColor standardBlueButtonColor];
    joinGroupButton.layer.cornerRadius = 5.0;
    frame.origin.y = CGRectGetMaxY(createGroupButton.frame) + 20.0;
    joinGroupButton.frame = frame;
    [joinGroupButton addTarget:self action:@selector(joinGroupButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:joinGroupButton];
    
    UILabel *invitationLabel = [[UILabel alloc] init];
    [invitationLabel setTextAlignment:NSTextAlignmentCenter];
    invitationLabel.textColor = [UIColor trophyYellowColor];
    invitationLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [invitationLabel setText:@"Invitation Code:"];
    frame.origin.x = floorf((CGRectGetWidth(self.view.bounds) - kGroupButtonWidth) / 2.0);
    frame.origin.y = CGRectGetMaxY(joinGroupButton.frame) + 10.0;
    invitationLabel.frame = frame;
    [self.view addSubview:invitationLabel];
    
    UIButton *inviteButton = [[UIButton alloc] init];
    [inviteButton setTitle:([TAGroupManager sharedManager].activeGroup.inviteCode) forState:UIControlStateNormal];
    //[TAGroupManager sharedManager].activeGroup.inviteCode;
    [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    inviteButton.backgroundColor = [UIColor trophyYellowColor];
    inviteButton.layer.cornerRadius = 5.0;
    frame = CGRectZero;
    frame.origin.x = floorf((CGRectGetWidth(self.view.bounds) - kGroupButtonWidth) / 2.0);
    frame.origin.y = CGRectGetMaxY(invitationLabel.frame) + 5.0;
    frame.size.width = kGroupButtonWidth;
    frame.size.height = kGroupButtonHeight;
    inviteButton.frame = frame;
    [self.view addSubview:inviteButton];
    
    
    
}

- (void)createGroupButtonPressed:(id)sender
{
    TACreateGroupViewController *createGroupVC = [[TACreateGroupViewController alloc] init];
    createGroupVC.delegate = self.delegate;
    [self.navigationController pushViewController:createGroupVC animated:YES];
}

- (void)joinGroupButtonPressed:(id)sender
{
    TAJoinGroupViewController *joinGroupVC = [[TAJoinGroupViewController alloc] init];
    joinGroupVC.delegate = self.delegate;
    [self.navigationController pushViewController:joinGroupVC animated:YES];
}

@end
