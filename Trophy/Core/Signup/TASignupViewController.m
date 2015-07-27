//
//  TASignupViewController.m
//  Trophy
//
//  Created by Gigster on 12/10/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import "TASignupViewController.h"

#import "TAActiveUserManager.h"
#import "TALoginViewController.h"
#import "TASignupView.h"
#import "TASettingsViewController.h"
#import "TATimelineViewController.h"

#import "TADefines.h"
#import "UIColor+TAAdditions.h"
#import <SVProgressHUD.h>

@interface TASignupViewController () <TASignupViewDelegate,
                                      TASettingsViewControllerDelegate,
                                      TALoginViewControllerDelegate>

@property (nonatomic, strong) TASignupView *signupView;

@end

@implementation TASignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.signupView = [[TASignupView alloc] initWithFrame:self.view.bounds];
    self.signupView.delegate = self;
    [self.view addSubview:self.signupView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - TASignupView Delegate Methods

- (void)signupViewDidPressContinueButton
{
    if ([self.signupView signupIsValid]) {
        [self.signupView startAnimating];
        BlockWeakSelf weakSelf = self;
        [[TAActiveUserManager sharedManager] registerWithUser:self.signupView.user success:^{
            [weakSelf transitionToSettingsViewController];
            [weakSelf.signupView stopAnimating];
            [weakSelf signupViewDidCreateUserWithSuccess];
        } failure:^(NSString *error) {
            [weakSelf.signupView stopAnimating];
            [SVProgressHUD showErrorWithStatus:error maskType:SVProgressHUDMaskTypeBlack];
        }];
    } else {
        NSString *errorString = [self.signupView signupError];
        if (errorString) {
            [SVProgressHUD showErrorWithStatus:errorString maskType:SVProgressHUDMaskTypeBlack];
        }
    }
}

- (void)signupViewDidPressLoginButton
{
    TALoginViewController *loginVC = [[TALoginViewController alloc] init];
    loginVC.delegate = self;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem.title = @"";
    self.navigationController.navigationBar.tintColor = [UIColor trophyYellowColor];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TASignupView Methods

- (void)signupViewDidCreateUserWithSuccess
{
    NSLog(@"Signup successful");
    [[TAActiveUserManager sharedManager] signupSuccessfulForActiveUser];
}

#pragma mark - TALoginViewController Delegate Methods

- (void)loginViewControllerDidLoginWithSuccess
{
    NSLog(@"Login successful");
    [[TAActiveUserManager sharedManager] refreshActiveUserWithSuccess:^{
        [[TAActiveUserManager sharedManager] accountSetupSuccessfulForActiveUser];
    } failure:^(NSString *error) {
        [SVProgressHUD showErrorWithStatus:error];
    }];
}

#pragma mark - Transition Methods

- (void)transitionToSettingsViewController
{
    TASettingsViewController *profileViewController = [[TASettingsViewController alloc] initWithSetupFlow:YES];
    profileViewController.delegate = self;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem.title = @"";
    self.navigationController.navigationBar.tintColor = [UIColor trophyYellowColor];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - TAProfileViewController Delegate Methods

- (void)settingsViewControllerDidUpdateProfileSettings
{
    [[TAActiveUserManager sharedManager] accountSetupSuccessfulForActiveUser];
}

@end
