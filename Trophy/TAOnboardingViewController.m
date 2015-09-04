//
//  TAOnboardingViewController.m
//  Trophy
//
//  Created by Robert Shaw on 7/23/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAOnboardingViewController.h"
#import "TAJoinGroupViewController.h"
#import "TAActiveUserManager.h"
#import "TASettingsViewController.h"


#import "UIColor+TAAdditions.h"
#import "TAGroupManager.h"

static const CGFloat welcomeLogoWidth = 300.0;
static const CGFloat welcomeLogoHeight = 50.0;
static const CGFloat kGroupButtonWidth = 150.0;
static const CGFloat kGroupButtonHeight = 40.0;

@interface TAOnboardingViewController () <TAPresentSettingsViewControllerDelegate, TASettingsViewControllerDelegate>

@end

@implementation TAOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // configures nav bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor trophyNavyColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
   
    // configures the onboarding View
    self.view.backgroundColor = [UIColor trophyNavyColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // adds trophy image
    UIImageView *trophyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home-logo"]];
    CGRect frame = trophyImageView.frame;
    frame.origin.x = CGRectGetMidX(self.view.bounds) - floorf(CGRectGetWidth(trophyImageView.frame) / 2.0);
    frame.origin.y = 60.0;
    trophyImageView.frame = frame;
    [self.view addSubview:trophyImageView];
    
    // configures welcome label
    UILabel *welcomeLabel = [[UILabel alloc] init];
    frame = welcomeLabel.frame;
    frame.size.width = welcomeLogoWidth;
    frame.size.height = welcomeLogoHeight;
    frame.origin.x = floorf((CGRectGetWidth(self.view.bounds) - welcomeLogoWidth) / 2.0) + 6.0;
    frame.origin.y = CGRectGetMaxY(trophyImageView.frame) + 25.0;
    welcomeLabel.frame = frame;
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    welcomeLabel.font = [UIFont fontWithName:@"Avenir" size:25.0];
    welcomeLabel.text = @"Have a group code?";
    welcomeLabel.textColor = [UIColor whiteColor];
    UIFont *font = welcomeLabel.font;
    welcomeLabel.font = [font fontWithSize:24];
    [self.view addSubview:welcomeLabel];
    
    // adds join group button
    UIButton *joinGroupButton = [[UIButton alloc] init];
    [joinGroupButton setTitle:@"Join Group" forState:UIControlStateNormal];
    joinGroupButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:20.0];
    [joinGroupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    joinGroupButton.backgroundColor = [UIColor darkerBlueColor];
    joinGroupButton.layer.cornerRadius = 5.0;
    frame = CGRectZero;
    frame.origin.x = floorf((CGRectGetWidth(self.view.bounds) - kGroupButtonWidth) / 2.0);
    frame.origin.y = CGRectGetMaxY(welcomeLabel.frame) + 25.0;
    frame.size.width = kGroupButtonWidth;
    frame.size.height = kGroupButtonHeight;
    joinGroupButton.frame = frame;
    
    // adds join button action trigger
    [joinGroupButton addTarget:self action:@selector(joinGroupButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:joinGroupButton];
    
    // adds settings button to view
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings-new-small"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(presentSettings:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    //leftButton.tintColor = [UIColor trophyYellowColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - action handlers

// handles join button press in onboardingView
- (void)joinGroupButtonPressed:(id)sender
{
    TAJoinGroupViewController *joinGroupVC = [[TAJoinGroupViewController alloc] init];
    joinGroupVC.delegate = self;
    [self.navigationController pushViewController:joinGroupVC animated:YES];
}

// handles action of back button press on settings view controller
- (void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - joinGroupViewController Delegate Methods

- (void)joinGroupViewControllerDidJoinGroup:(TAJoinGroupViewController *)joinGroupViewController
{
    NSLog(@"Onboarding successful");
    [[TAActiveUserManager sharedManager] onboardingSuccessfulForActiveUser];
}

#pragma mark - presentSettingsViewController Delegate Methods

// presents the settings view contolller
- (void)presentSettings:(UIViewController *)viewController
{
    TASettingsViewController *settingsVC = [[TASettingsViewController alloc] initWithSetupFlow:NO];
    settingsVC.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    settingsVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - settingsViewController Delegate Methods

// handles successful update by jumping back to onboarding view
- (void)settingsViewControllerDidUpdateProfileSettings
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end

