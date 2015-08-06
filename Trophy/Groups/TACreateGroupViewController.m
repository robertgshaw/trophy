//
//  TACreateGroupViewController.m
//  Trophy
//
//  Created by Gigster on 1/24/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TACreateGroupViewController.h"

#import "TAActiveUserManager.h"
#import "TACreateGroupView.h"
#import "TAGroup.h"
#import "TAGroupInviteViewController.h"
#import "TAGroupManager.h"

#import "UIColor+TAAdditions.h"
#import <SVProgressHUD.h>
#include <stdlib.h>

static const NSString *kInviteCodeLetterSet = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
static const NSInteger kInviteCodeLength = 6;

@interface TACreateGroupViewController () <TACreateGroupViewDelegate,
                                           TAGroupInviteViewControllerDelegate>

@property (nonatomic, strong) TACreateGroupView *createGroupView;
@property (nonatomic, strong) TAGroup *group;
@property (nonatomic, strong) NSString *inviteCode;

@end

@implementation TACreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"New Group";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(nextButtonPressed)];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.createGroupView = [[TACreateGroupView alloc] initWithFrame:self.view.bounds];
    self.createGroupView.delegate = self;
    [self.view addSubview:self.createGroupView];
    
    self.inviteCode = [self generateInviteCode];
}

- (void)nextButtonPressed
{
    if ([self.createGroupView.groupName isEqualToString:@"TestGroup"]) {
        [SVProgressHUD showErrorWithStatus:@"Oops! That is a reserved name. Try a different group name."
                                  maskType:SVProgressHUDMaskTypeBlack];
    } else {
        TAGroupInviteViewController *groupInviteVC = [[TAGroupInviteViewController alloc] init];
        groupInviteVC.delegate = self;
        groupInviteVC.groupName = self.createGroupView.groupName;
        groupInviteVC.inviteCode = self.inviteCode;
        [self.navigationController pushViewController:groupInviteVC animated:YES];
    }
}

-(NSString *)generateInviteCode
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity:kInviteCodeLength];
    
    for (int i = 0; i < kInviteCodeLength; i++) {
        [randomString appendFormat: @"%C", [kInviteCodeLetterSet characterAtIndex:arc4random_uniform((int)[kInviteCodeLetterSet length])]];
    }
    return randomString;
}

#pragma mark - TACreateGroupViewDelegate Methods

- (void)createGroupViewShouldShowNextButton:(TACreateGroupView *)createGroupView enabled:(BOOL)enabled
{
    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

- (void)createGroupViewDidFinishEnteringInformation:(TACreateGroupView *)createGroupView
{
    [self nextButtonPressed];
}

#pragma mark - TAGroupInviteViewControllerDelegate Methods

- (void)groupInviteViewControllerDidPressDone:(TAGroupInviteViewController *)groupInviteViewController
{
    // Create local group
    self.group = [[TAGroup alloc] init];
    self.group.name = self.createGroupView.groupName;
    self.group.inviteCode = self.inviteCode;
    [TAGroupManager sharedManager].activeGroup = self.group;
    
    [[TAGroupManager sharedManager] createGroup:self.group
                                        success:^(TAGroup *group) {
                                            [TAGroupManager sharedManager].activeGroup = group;
                                            [self.delegate createGroupViewControllerDidCreateGroup:self];
                                        } failure:^(NSString *error) {
                                            [SVProgressHUD showErrorWithStatus:error maskType:SVProgressHUDMaskTypeBlack];
                                        }];
}

@end
