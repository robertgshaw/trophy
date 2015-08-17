//
//  TALeaderboardViewController.m
//  Trophy
//
//  Created by Gigster on 12/25/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import "TALeaderboardViewController.h"

#import "TADefines.h"
#import "TAGroup.h"
#import "TAGroupListViewController.h"
#import "TAGroupManager.h"
#import "TALeaderboardTableViewCell.h"
#import "TALeaderboardScore.h"
#import "TAProfileViewController.h"

#import "UIColor+TAAdditions.h"
#import <Parse/Parse.h>

static const CGFloat kGroupsButtonWidth = 80.0;
static const CGFloat kGroupsButtonHeight = 70.0;

@interface TALeaderboardViewController () <UITableViewDataSource,
                                           UITableViewDelegate,
                                           TAGroupListViewControllerDelegate>

@property (nonatomic, strong) TAGroup *currentGroup;
@property (nonatomic, strong) NSMutableArray *ranks;
@property (nonatomic, assign) BOOL isRanking;

@property (nonatomic, strong) TAGroupListViewController *groupListVC;
@property (nonatomic, strong) UIButton *backgroundTap;
@property (nonatomic, strong) CAShapeLayer *formatGroupsLayer;

@end

@implementation TALeaderboardViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.parseClassName = @"Leaderboard";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 10;
        self.ranks = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@""
                                                    image:[UIImage imageNamed:@"timeline-tab-button.png"]
                                            selectedImage:[UIImage imageNamed:@"timeline-tab-button-selected.png"]];
    self.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    [self layoutGroupsButton];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user-settings-icon"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(presentSettings)];
    self.navigationItem.leftBarButtonItem = leftButton;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user-profile-icon"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(presentProfile)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    // configures nav bar display
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor darkYellowColor];
    
    self.backgroundTap = [[UIButton alloc] initWithFrame:self.view.bounds];
    [self.backgroundTap addTarget:self action:@selector(backgroundDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backgroundTap];
    self.backgroundTap.enabled = NO;
    
    [self layoutGroupListView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    TAGroup *activeGroup = [TAGroupManager sharedManager].activeGroup;
    if (self.currentGroup && [self.currentGroup.groupId isEqualToString:activeGroup.groupId] == NO) {
        [self loadObjects];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.groupListVC.view.hidden = YES;
}

- (PFQuery *)queryForTable
{
    TAGroup *activeGroup = [TAGroupManager sharedManager].activeGroup;
    self.currentGroup = activeGroup;
    PFQuery *query = [PFQuery queryWithClassName:@"LeaderboardScore"];
    [query whereKey:@"groupId" equalTo:activeGroup.groupId];
    [query orderByDescending:@"trophyCount"];
    [query includeKey:@"user"];
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    return query;
}

- (void)layoutGroupsButton
{

    UIButton *groupListButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kGroupsButtonWidth, kGroupsButtonHeight)];
    [groupListButton addTarget:self action:@selector(groupListButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    UIView *groupListView = [[UIView alloc] initWithFrame:groupListButton.frame];
    
    UILabel *groupListLabel = [[UILabel alloc] init];
    groupListLabel.text = @"Hall of Fame";
    groupListLabel.textColor = [UIColor whiteColor];
    groupListLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:20.0];
    [groupListLabel sizeToFit];
    [groupListView addSubview:groupListLabel];
   
    UIImageView *downArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down-arrow"]];
    [groupListView addSubview:downArrowImageView];
    
    CGRect frame = groupListLabel.frame;
    frame.origin.x = floorf((kGroupsButtonWidth - CGRectGetWidth(groupListLabel.frame) - CGRectGetWidth(downArrowImageView.frame) - 3.0) / 2.0);
    frame.origin.y = floorf((kGroupsButtonHeight - CGRectGetHeight(groupListLabel.frame)) / 2.0);
    groupListLabel.frame = frame;
    
    frame = downArrowImageView.frame;
    frame.origin.x = CGRectGetMaxX(groupListLabel.frame) + 3.0;
    frame.origin.y = floorf((kGroupsButtonHeight - CGRectGetHeight(downArrowImageView.frame)) / 2.0);
    downArrowImageView.frame = frame;
    [groupListButton addSubview:groupListView];
    groupListView.userInteractionEnabled = NO;
    self.navigationItem.titleView = groupListButton;
}

- (void)layoutGroupListView
{
    self.groupListVC = [[TAGroupListViewController alloc] init];
    self.groupListVC.delegate = self;
    self.groupListVC.view.hidden = YES;
    CGFloat width = 300.0;
    CGRect frame = self.groupListVC.view.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.view.bounds) - width) / 2.0);
    frame.origin.y = 0.0;
    frame.size.width = width;
    self.groupListVC.view.frame = frame;
    [self.groupListVC.view.layer setBorderColor:[UIColor trophyYellowColor].CGColor];
    [self.groupListVC.view.layer setBorderWidth:2.0];
    [self addChildViewController:self.groupListVC];
    [self.groupListVC didMoveToParentViewController:self];
}

- (void)groupListButtonDidPress
{
    if (self.groupListVC.view.hidden) {
        self.groupListVC.view.hidden = NO;
        CGFloat verticalOffset = self.tableView.contentOffset.y;
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGRect frame = self.groupListVC.view.frame;
        frame.size.height = [self.groupListVC heightForList];
        frame.origin.y = verticalOffset + CGRectGetHeight(self.navigationController.navigationBar.frame) + statusBarHeight;
        self.groupListVC.view.frame = frame;
        [self.view addSubview:self.groupListVC.view];
        self.tableView.scrollEnabled = NO;
        
        frame = self.backgroundTap.frame;
        frame.origin.y = CGRectGetMinY(self.groupListVC.view.frame);
        self.backgroundTap.frame = frame;
        self.backgroundTap.enabled = YES;
        [self formatGroupsView];
    } else {
        self.groupListVC.view.hidden = YES;
        [self.groupListVC.view removeFromSuperview];
        self.tableView.scrollEnabled = YES;
        self.backgroundTap.enabled = NO;
    }
}

- (void)formatGroupsView
{
    if (self.formatGroupsLayer) {
        [self.formatGroupsLayer removeFromSuperlayer];
        self.formatGroupsLayer = nil;
    }
    CGRect bounds = self.groupListVC.view.bounds;
    bounds.size.height = [self.groupListVC heightForList];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight)
                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.groupListVC.view.layer.mask = maskLayer;
    
    CAShapeLayer *frameLayer = [CAShapeLayer layer];
    frameLayer.frame = bounds;
    frameLayer.path = maskPath.CGPath;
    frameLayer.lineWidth = 5.0;
    frameLayer.strokeColor = [UIColor trophyYellowColor].CGColor;
    frameLayer.fillColor = nil;
    self.formatGroupsLayer = frameLayer;
    [self.groupListVC.view.layer addSublayer:self.formatGroupsLayer];
}

- (void)backgroundDidTap:(id)sender
{
    [self groupListButtonDidPress];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentSize.height - scrollView.contentOffset.y < (self.view.bounds.size.height)) {
        if ([self isLoading] == NO) {
            [self loadNextPage];
        }
    }
}

#pragma mark - UITableView Datasource Methods

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    if (indexPath.row >= [self.objects count]) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath object:object];
    }
    
    TALeaderboardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TALeaderboardTableViewCell class])];
    if (cell == nil)
        cell = [[TALeaderboardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([TALeaderboardTableViewCell class])];

    TALeaderboardScore *score = [[TALeaderboardScore alloc] initWithStoredLeaderboardScore:object includeUser:YES];
    cell.score = score;
    NSInteger rank;
    if (indexPath.row == 0) {
        self.ranks[0] = @1;
        rank = 1;
    } else {
        PFObject *currentObject = self.objects[indexPath.row];
        NSInteger currentTrophyCount = [currentObject[@"trophyCount"] integerValue];
        PFObject *lastObject = self.objects[indexPath.row - 1];
        NSInteger lastTrophyCount = [lastObject[@"trophyCount"] integerValue];
        if (currentTrophyCount == lastTrophyCount) {
            self.ranks[indexPath.row] = self.ranks[indexPath.row - 1];
        } else {
            self.ranks[indexPath.row] = [NSNumber numberWithLong:indexPath.row + 1];
        }
        rank = [self.ranks[indexPath.row] integerValue];
    }
    [cell setRank:rank];
    return cell;
}

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath
{
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PFTableViewCell class])];
    if (cell == nil)
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([PFTableViewCell class])];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell addSubview:indicatorView];
    indicatorView.center = CGPointMake(self.view.center.x, cell.center.y);
    [indicatorView startAnimating];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.objects count]) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    TALeaderboardTableViewCell *cell = (TALeaderboardTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [cell heightForCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    TAUser *user = [[TAUser alloc] initWithStoredUser:((PFUser *)object[@"user"])];
    [self presentProfile:user];
}

#pragma mark - UINavigation Methods

- (void)presentSettings
{
    [self.presentedDelegate presentSettings:self];
}

- (void)presentProfile
{
    [self.presentedDelegate presentProfile:self];
}

- (void)presentProfile:(TAUser *)user
{
    TAProfileViewController *profileVC = [[TAProfileViewController alloc] initWithUser:user];
    [self.navigationController pushViewController:profileVC animated:YES];
}

#pragma mark - TAGroupListViewControllerDelegate Methods

- (void)groupListViewControllerDidReloadGroups:(TAGroupListViewController *)groupListViewController
{
    CGRect frame = self.groupListVC.view.frame;
    frame.size.height = [self.groupListVC heightForList];
    self.groupListVC.view.frame = frame;
}

- (void)groupListViewControllerDidChangeGroups:(TAGroupListViewController *)groupListViewController
{
    self.groupListVC.view.hidden = YES;
    [self.groupListVC.view removeFromSuperview];
    [self loadObjects];
}

- (void)groupListViewControllerDidAddGroup:(TAGroupListViewController *)groupListViewController
{
    [self loadObjects];
}

#pragma mark - Private methods

- (NSString *)rankStringForNumber:(NSInteger)number {
    NSString *numStr = [NSString stringWithFormat:@"%ld", (long)number];
    NSString *lastDigit = [numStr substringFromIndex:([numStr length] - 1)];
    
    NSString *ordinal;
    if ([numStr isEqualToString:@"11"] || [numStr isEqualToString:@"12"] || [numStr isEqualToString:@"13"]) {
        ordinal = @"th";
    } else if ([lastDigit isEqualToString:@"1"]) {
        ordinal = @"st";
    } else if ([lastDigit isEqualToString:@"2"]) {
        ordinal = @"nd";
    } else if ([lastDigit isEqualToString:@"3"]) {
        ordinal = @"rd";
    } else {
        ordinal = @"th";
    }
    return [NSString stringWithFormat:@"%@%@", numStr, ordinal];
}

@end
