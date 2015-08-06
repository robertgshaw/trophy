//
//  TALoginViewController.m
//  Trophy
//
//  Created by Gigster on 1/2/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TALoginViewController.h"

#import "TAActiveUserManager.h"
#import "TALoginView.h"

#import "TADefines.h"
#import "UIColor+TAAdditions.h"
#import <SVProgressHUD.h>

@interface TALoginViewController () <TALoginViewDelegate>

@property (nonatomic, strong) TALoginView *loginView;

@end

@implementation TALoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor darkYellowColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"Login";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;

    self.loginView = [[TALoginView alloc] initWithFrame:self.view.bounds];
    self.loginView.delegate = self;
    [self.view addSubview:self.loginView];
}

#pragma mark - TALoginView Delegate Methods

- (void)loginViewDidPressContinue:(TALoginView *)loginView
{
    if ([self.loginView validateLogin]) {
        NSDictionary *loginParameters;
        [self.loginView startAnimating];
        if (self.loginView.usernameSelected) {
            loginParameters = @{@"username": self.loginView.username,
                                @"password": self.loginView.password};
        } else {
            loginParameters = @{@"phoneNumber": self.loginView.phoneNumber,
                                @"password": self.loginView.password};
        }
        BlockWeakSelf weakSelf = self;
        [[TAActiveUserManager sharedManager] loginWithParameters:loginParameters
                                                         success:^{
                                                             [weakSelf.delegate loginViewControllerDidLoginWithSuccess];
                                                         } failure:^(NSString *error) {
                                                             [weakSelf.loginView stopAnimating];
                                                             [SVProgressHUD showErrorWithStatus:error maskType:SVProgressHUDMaskTypeBlack];
                                                         }];
    }
}

@end
