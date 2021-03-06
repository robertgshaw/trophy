//
//  TAProfileViewController.m
//  Trophy
//
//  Created by Gigster on 1/11/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAProfileViewController.h"

#import "TAProfileHeaderView.h"
#import "TASettingsViewController.h"
#import "TATrophyCollectionViewController.h"
#import "TATrophyManager.h"
#import "UIColor+TAAdditions.h"

#import <SVProgressHUD.h>

static const CGFloat kProfileHeaderMinHeight = 100.0;

@interface TAProfileViewController ()<TAProfileHeaderViewDelegate,
                                      TASettingsViewControllerDelegate>

@property (nonatomic, strong) TAUser *user;
@property (nonatomic, strong) TAProfileHeaderView *profileHeaderView;
@property (nonatomic, strong) TATrophyCollectionViewController *trophyCollectionViewController;

@end

@implementation TAProfileViewController

- (instancetype)initWithUser:(TAUser *)user
{
    self = [super init];
    if (self) {
        _user = user;
        
        self.profileHeaderView = [[TAProfileHeaderView alloc] initWithFrame:CGRectZero];
        self.profileHeaderView.delegate = self;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        self.trophyCollectionViewController = [[TATrophyCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
        self.trophyCollectionViewController.delegate = self;
        
        [self loadObjects];
    }
    return self;
}

- (void)loadObjects
{
    [[TATrophyManager sharedManager] refreshUser:self.user success:^(TAUser *user) {
        self.profileHeaderView.user = user;
        self.user = user;
        [self layoutHeader];
    } failure:^(NSString *error) {
        [SVProgressHUD showErrorWithStatus:error maskType:SVProgressHUDMaskTypeBlack];
    }];
    
    [[TATrophyManager sharedManager] getLeaderboardScoreForUser:self.user inGroup:nil success:^(TALeaderboardScore *score) {
        self.profileHeaderView.leaderboardScore = score;
        [self layoutHeader];
    } failure:^(NSString *error) {
        [SVProgressHUD showErrorWithStatus:error maskType:SVProgressHUDMaskTypeBlack];
    }];
    
    [[TATrophyManager sharedManager] getTrophiesForUser:self.user success:^(NSArray *trophies) {
        self.trophyCollectionViewController.trophies = trophies;
    } failure:^(NSString *error) {
        [SVProgressHUD showErrorWithStatus:error maskType:SVProgressHUDMaskTypeBlack];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Loading settings information");
    
    // adds the color to the navigation bar
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // adds title label to the profile view
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"Trophy Case";
    titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:20.0];

    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
 
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.profileHeaderView];
    [self.view addSubview:self.trophyCollectionViewController.view];
    [self addChildViewController:self.trophyCollectionViewController];
    [self.trophyCollectionViewController didMoveToParentViewController:self];
    
    [self layoutHeader];
}

- (void)layoutHeader
{
    CGFloat profileHeaderHeight = MAX(kProfileHeaderMinHeight, [self.profileHeaderView heightForProfileHeader]);
    self.profileHeaderView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), profileHeaderHeight);
    self.trophyCollectionViewController.view.frame = CGRectMake(0, CGRectGetMaxY(self.profileHeaderView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - profileHeaderHeight);
}

#pragma mark - TAProfileHeaderViewDelegate Methods

- (void)profileHeaderViewDidPressEdit:(TAProfileHeaderView *)profileHeaderView
{
    TASettingsViewController *settingsVC = [[TASettingsViewController alloc] initWithSetupFlow:NO];
    settingsVC.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    settingsVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - TASettingsViewControllerDelegate Methods

- (void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsViewControllerDidUpdateProfileSettings {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
