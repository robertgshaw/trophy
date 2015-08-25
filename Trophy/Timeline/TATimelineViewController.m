//
//  TATimelineViewController.m
//  Trophy
//
//  Created by Gigster on 12/22/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import "TATimelineViewController.h"

#import "TAActiveUserManager.h"
#import "TADefines.h"
#import "TAGroupListViewController.h"
#import "TAGroupManager.h"
#import "TAProfileViewController.h"
#import "TATimelineTableViewCell.h"
#import "TATrophy.h"
#import "TATrophyCloseupViewController.h"
#import "TASettingsViewController.h"
#import "TACommentTableViewController.h"
#import "TAGroupListButton.h"
#import "UIColor+TAAdditions.h"
#import "TACommentButton.h"

static const CGFloat kGroupsButtonWidth = 80.0;
static const CGFloat kGroupsButtonHeight = 70.0;

@interface TATimelineViewController () <UITableViewDataSource,
                                        UITableViewDelegate,
                                        TALikeButtonDelegate,
                                        TATimelineTableViewCellDelegate,
                                        TACommentTableViewControllerDelegate,
                                        TAGroupListViewControllerDelegate,
                                        TATrophyCloseupViewControllerDelegate>

@property (nonatomic, strong) TAGroupListViewController *groupListVC;
@property (nonatomic, strong) TAGroup *currentGroup;
@property (nonatomic, strong) UIButton *backgroundTap;
@property (nonatomic, strong) UIImageView *zeroContentImage;
@property (nonatomic, strong) CAShapeLayer *formatGroupsLayer;
@property (nonatomic, strong) TAGroupListButton *groupListButton;
@property (nonatomic, strong) NSIndexPath *indexPathOfCurrentSelectedCell;
@property (nonatomic, strong) TATimelineTableViewCell *prototypeCell;

@end

@implementation TATimelineViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.parseClassName = @"Timeline";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 7;
        self.loadingViewEnabled = YES;
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
    self.tabBarController.tabBar.barTintColor = [UIColor trophyNavyColor];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];

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
    
    // change color
    rightButton.tintColor = [UIColor whiteColor];
    leftButton.tintColor = [UIColor whiteColor];
    
    //change top bar icon collor
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor trophyNavyColor];
    self.navigationController.navigationBar.translucent = NO;
    
    //change bottom bar icon color
    self.tabBarController.tabBar.barStyle = UIBarStyleDefault;
    
    self.backgroundTap = [[UIButton alloc] initWithFrame:self.view.bounds];
    [self.backgroundTap addTarget:self action:@selector(backgroundDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backgroundTap];
    self.backgroundTap.enabled = NO;
    
    [self layoutGroupListView];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //sets active group
    
    TAGroup *activeGroup = [TAGroupManager sharedManager].activeGroup;
    if (self.currentGroup && [self.currentGroup.groupId isEqualToString:activeGroup.groupId] == NO) {
        [self loadObjects];
    }
    
    self.navigationController.navigationBarHidden = NO;

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
    PFQuery *query = [PFQuery queryWithClassName:@"Trophy"];
    [query whereKey:@"groupId" equalTo:activeGroup.groupId];
    [query includeKey:@"recipient"];
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    return query;
}

- (void) objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
    // removes separator between cells
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // if no objects loaded, display the vacant timeline image
    if ([self.objects count] == 0)
    {
        // configures empty timeline display
        self.zeroContentImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.zeroContentImage.image = [UIImage imageNamed:@"zero-content-timeline"];
        // lays out the empty timeline display
        CGRect frame = self.zeroContentImage.frame;
        frame.size.width = self.view.frame.size.width;
        frame.size.height = (frame.size.width / self.zeroContentImage.image.size.width) * self.zeroContentImage.image.size.height;
        frame.origin.x = 0;
        frame.origin.y = (CGRectGetMinY(self.view.frame)-30.0);
        self.zeroContentImage.frame = frame;
        [self.view addSubview:self.zeroContentImage];
        
        self.zeroContentImage.hidden = NO;
        
    } else {
        self.zeroContentImage.hidden = YES;
    }
}


// loads second page of objects
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentSize.height - scrollView.contentOffset.y < (self.view.bounds.size.height)) {
        if ([self isLoading] == NO) {
            [self loadNextPage];
        }
    }
}

#pragma mark - UITableView Datasource Methods

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPage";
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"Load more...";
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor trophyNavyColor];
    
    return cell;
}

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    TATimelineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TATimelineTableViewCell class])];
    if (cell == nil)
        cell = [[TATimelineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([TATimelineTableViewCell class])];
    if (floor(fmodf(indexPath.row, 2.0)) == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    // sets the cell's delegate
    cell.delegate = self;
    cell.likesButton.delegate = self;
    
    // sets the cells image as a placeholder
    if (cell.imageView.image == nil)
    {
        cell.imageView.image = [UIImage imageNamed:@"default-profile-icon"];
    }
    // configures the cell with data
    [self setCell:cell withObject:object];
    
    return cell;
   
}

// sets the data for a particular cell
- (void) setCell:(TATimelineTableViewCell *)cell withObject:(PFObject *)object
{
    // after the image loads, add it in
    PFFile *imageFile = [object objectForKey:@"imageFile"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                        cell.imageView.image = [UIImage imageWithData:data];
    }];

    
    // set up caption label, author label, date label
    cell.descriptionLabel.text = object[@"caption"];
    cell.authorLabel.text = [NSString stringWithFormat:@"%@ awarded %@ for:", object[@"author"][@"name"], object[@"recipient"][@"name"]];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@" , [cell formatDate:object[@"time"]]];
    
    // sets comments label, button
    if (object[@"commentNumber"] == nil) {
        cell.commentsLabel.text = @"0 comments";
    } else {
        NSInteger commentNumber = [object[@"commentNumber"] integerValue];
        cell.commentsLabel.text = [NSString stringWithFormat:@"%i comments", (int)commentNumber];
    }
    [cell.commentsButton addTarget:self action:@selector(presentTrophyComments:) forControlEvents:UIControlEventTouchUpInside];

    // configures like button with a trophy
    cell.likesButton.trophy = [[TATrophy alloc] initWithStoredTrophy:object];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (indexPath.row == [self.objects count]) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    // cell height is 1.25 * width of table view
    return self.tableView.frame.size.width * 1.25;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // cell for next page, loads the next page of objects
    if (indexPath.row == [self.objects count])
    {
        if ([self isLoading] == NO) {
            [self loadNextPage];
        }
    // otherwise, present trophy closeup
    } else {
        // parse query
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        TATrophy *trophy = [[TATrophy alloc] initWithStoredTrophy:object];

        // sets index path of current closeup
        if ([[self tableView:tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[TATimelineTableViewCell class]]) {
            self.indexPathOfCurrentSelectedCell = indexPath;
        }
        [self presentTrophyCloseup:trophy];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.groupListVC.view.hidden == NO) {
        return NO;
    } else {
        return YES;
    }
}

- (void)layoutGroupsButton
{
    // initializes group list button
    self.groupListButton = [[TAGroupListButton alloc] initWithFrame:CGRectMake(0, 0, kGroupsButtonWidth, kGroupsButtonHeight)];
    [self.groupListButton addTarget:self action:@selector(groupListButtonDidPress) forControlEvents:UIControlEventTouchUpInside];
    
    // adds group list button to view
    self.navigationItem.titleView = self.groupListButton;
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
    [self.groupListVC.view.layer setBorderColor:[UIColor trophyNavyColor].CGColor];
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
        frame.origin.y = verticalOffset;
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
    frameLayer.strokeColor = [UIColor trophyNavyColor].CGColor;
    frameLayer.fillColor = nil;
    self.formatGroupsLayer = frameLayer;
    [self.groupListVC.view.layer addSublayer:self.formatGroupsLayer];
}

- (void)backgroundDidTap:(id)sender
{
    [self groupListButtonDidPress];
}


#pragma mark - Helper Methods

// reloads a particular cell which was just "closeup"
- (void)reloadSelectedCellWithUpdatedTrophy:(TATrophy *)updatedTrophy;
{
    // ensure there is a current closeup
    if (self.indexPathOfCurrentSelectedCell != nil)
    {
        // fetch the one row that needs to be refreshed, reload ui
        PFObject *objectToUpdate = [self objectAtIndexPath:self.indexPathOfCurrentSelectedCell];
        [objectToUpdate fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[self.indexPathOfCurrentSelectedCell] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }];
    }
}

#pragma mark - TACommentTableViewControllerDelegate Methods

- (void)trophyCommentDidPerformAction:(TATrophy *)updatedTrophy
{
    [self reloadSelectedCellWithUpdatedTrophy:updatedTrophy];
}

- (void)trophyCommentViewControllerDidPressBackButton
{
     [self jumpToTimelineWithNavBarHidden:NO];
}

#pragma mark - TATrophyCloseupViewControllerDelegate

- (void)trophyCloseupDidPerformAction:(TATrophy *)updatedTrophy
{
    [self reloadSelectedCellWithUpdatedTrophy:updatedTrophy];
}

- (void)closeUpViewControllerBackButtonPressed
{
    self.navigationController.navigationBar.barTintColor = [UIColor trophyNavyColor];
    [self jumpToTimelineWithNavBarHidden:NO];
}

#pragma mark - TALkesButtonDelegate Methods

- (void)likesButtonDidPressLikesButton:(TATrophy *)updatedTrophy
{
    [self reloadSelectedCellWithUpdatedTrophy:updatedTrophy];
}

#pragma mark - TATimelineTableViewCellDelegate Methods

- (void)timelineCellDidPressProfileButton:(TATimelineTableViewCell *)cell forUser:(TAUser *)user
{
    [self presentUserProfile:user];
}

#pragma mark - TAGroupListViewControllerDelegate Methods

- (void)groupListViewControllerDidReloadGroups:(TAGroupListViewController *)groupListViewController
{
    CGRect frame = self.groupListVC.view.frame;
    frame.size.height = [self.groupListVC heightForList];
    self.groupListVC.view.frame = frame;
    [self.groupListButton updateGroupsButtonWithName:[TAGroupManager sharedManager].activeGroup.name];
}

- (void)groupListViewControllerDidChangeGroups:(TAGroupListViewController *)groupListViewController
{
    self.groupListVC.view.hidden = YES;
    [self.groupListVC.view removeFromSuperview];
    [self loadObjects];
    [self.groupListButton updateGroupsButtonWithName:[TAGroupManager sharedManager].activeGroup.name];
}

- (void)groupListViewControllerDidAddGroup:(TAGroupListViewController *)groupListViewController
{
    [self loadObjects];
    [self.groupListButton updateGroupsButtonWithName:[TAGroupManager sharedManager].activeGroup.name];
}

#pragma mark - UINavigation Methods

// "pops" back to the timeline after closeup
- (void)jumpToTimelineWithNavBarHidden:(BOOL)enabled
{
    // "unselects" cell
    self.indexPathOfCurrentSelectedCell = nil;
    
    // pops to the timeline view controller
    [self.navigationController popToViewController:self animated:YES];
    
    // displays the nav bar and the tab bar
    self.navigationController.navigationBarHidden = enabled;
}

- (void)presentSettings
{
    [self.presentedDelegate presentSettings:self];
}

- (void)presentProfile
{
    [self.presentedDelegate presentProfile:self];
}

- (void)presentUserProfile:(TAUser *)user
{
    TAProfileViewController *profileVC = [[TAProfileViewController alloc] initWithUser:user];
    
    // adds navigation item to the view
    profileVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];

    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)backButtonPressed
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentTrophyCloseup:(TATrophy *)trophy
{
    TATrophyCloseupViewController *closeupViewController = [[TATrophyCloseupViewController alloc] initWithTrophy:trophy];
    closeupViewController.delegate = self;
    closeupViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:closeupViewController animated:YES];
 
}

-(void)presentTrophyComments:(id)sender
{
    TACommentButton *button = sender;
    
    self.indexPathOfCurrentSelectedCell = [self.tableView indexPathForCell:(TATimelineTableViewCell *)button.superview];
    
    // pass object to TACommentTableViewController as a TATrophy
    TACommentTableViewController *commentVC = [[TACommentTableViewController alloc] initWithPhoto: [[TATrophy alloc] initWithStoredTrophy: [self.objects objectAtIndex:self.indexPathOfCurrentSelectedCell.row]]];
    commentVC.delegate = self;
    [self.navigationController pushViewController:commentVC animated:YES];
}

@end
