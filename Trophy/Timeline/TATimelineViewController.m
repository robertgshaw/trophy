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
                                        TATimelineTableViewCellDelegate,
                                        TACommentTableViewControllerDelegate,
                                        TAGroupListViewControllerDelegate,
                                        TATrophyCloseupViewControllerDelegate>

@property (nonatomic, strong) TAGroupListViewController *groupListVC;
@property (nonatomic, strong) TAGroup *currentGroup;
@property (nonatomic, strong) UIButton *backgroundTap;
@property (nonatomic, strong) CAShapeLayer *formatGroupsLayer;
@property (nonatomic, strong) TAGroupListButton *groupListButton;
@property (nonatomic, strong) NSIndexPath *indexPathOfCurrentSelectedCell;

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
    
    // change color
    rightButton.tintColor = [UIColor whiteColor];
    leftButton.tintColor = [UIColor whiteColor];
    
    //change top bar icon collor
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor darkYellowColor];
    
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
    TAGroup *activeGroup = [TAGroupManager sharedManager].activeGroup;
    if (self.currentGroup && [self.currentGroup.groupId isEqualToString:activeGroup.groupId] == NO) {
        [self loadObjects];
    }
    
    // displays the nav bar and the tab bar - accounts for transition from comments view table
    self.navigationController.navigationBarHidden = NO;

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.groupListVC.view.hidden = YES;
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
    [self.groupListVC.view.layer setBorderColor:[UIColor trophyYellowColor].CGColor];
    [self.groupListVC.view.layer setBorderWidth:2.0];
    [self addChildViewController:self.groupListVC];
    [self.groupListVC didMoveToParentViewController:self];
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
    TATimelineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TATimelineTableViewCell class])];
    if (cell == nil)
        cell = [[TATimelineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([TATimelineTableViewCell class])];
    if (floor(fmodf(indexPath.row, 2.0)) == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    // sets the cells trophy based on parse query
    cell.trophy = [[TATrophy alloc] initWithStoredTrophy:object];
    
    // set properties on commentsButton and commentsLabel from the tableView cell
    cell.commentsButton.trophy = cell.trophy;
    PFObject *trophyObject = [cell.trophy getTrophyAsParseObject];
    cell.commentsLabel.text = [NSString stringWithFormat:@"%@ comments", trophyObject[@"commentNumber"]];
    if(trophyObject[@"commentNumber"] == nil) {
        cell.commentsLabel.text = @"0 comments";
        cell.commentsLabel.font = [UIFont fontWithName:@"Avenir-Book" size:12.0];
    
    }
    cell.commentsLabel.text = [NSString stringWithFormat:@"%ld comments", (long)cell.trophy.commentNumber];
<<<<<<< HEAD

    [cell.commentsButton addTarget:self action:@selector(presentTrophyComments:) forControlEvents:UIControlEventTouchUpInside];
    cell.delegate = self;
    return cell;
=======
    cell.commentsLabel.font = [UIFont fontWithName:@"Avenir-Book" size:12.0];

>>>>>>> kenny
    
        // THE FOLLOWING COMMENTED-OUT CODE WAS FOR EXPERIMENTATION PURPOSES
//    UITapGestureRecognizer *labelTapRecognizer = [[UITapGestureRecognizer alloc] init];
//    [labelTapRecognizer addTarget:self action:@selector(presentTrophyCommentsFromLabel:)];
//    [labelTapRecognizer setNumberOfTapsRequired:1];
//    [cell.commentsLabel addGestureRecognizer:labelTapRecognizer];
//    [cell bringSubviewToFront:cell.commentsLabel];
   
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
    if (indexPath.row == [self.objects count]) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    TATimelineTableViewCell *cell = (TATimelineTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [cell heightOfCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    // parse query
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    TATrophy *trophy = [[TATrophy alloc] initWithStoredTrophy:object];

    // sets index path of current closeup
    if ([[self tableView:tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[TATimelineTableViewCell class]]) {
        
        self.indexPathOfCurrentSelectedCell = indexPath;
    }
    [self presentTrophyCloseup:trophy];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.groupListVC.view.hidden == NO) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - helper methods
- (void)reloadSelectedCellWithUpdatedTrophy:(TATrophy *)updatedTrophy;
{
    // updates only the current closeup cell when an action is performed
    if (self.indexPathOfCurrentSelectedCell != nil)
    {
        
        PFObject *objectToUpdate = [self objectAtIndexPath:self.indexPathOfCurrentSelectedCell];
        
        NSLog(@"%@", objectToUpdate[@"commentNumber"]);
        [objectToUpdate fetchInBackground];
        NSLog(@"%@", objectToUpdate[@"commentNumber"]);
    }
}

- (void)jumpToTimelineWithNavBarHidden:(BOOL)enabled
{
    // "unselects" cell
    self.indexPathOfCurrentSelectedCell = nil;
    
    // pops to the timeline view controller
    [self.navigationController popToViewController:self animated:YES];
    
    // displays the nav bar and the tab bar
    self.navigationController.navigationBarHidden = enabled;

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

- (void) closeUpViewControllerBackButtonPressed
{
    self.navigationController.navigationBar.barTintColor = [UIColor trophyYellowColor];
    [self jumpToTimelineWithNavBarHidden:NO];
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

// handles back button presses
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
    
    TACommentTableViewController *commentVC = [[TACommentTableViewController alloc] initWithPhoto:button.trophy];
    commentVC.delegate = self;
    [self.navigationController pushViewController:commentVC animated:YES];
}

// AFFILIATED EXPERIMENTAL FUNCTIONS TO ABOVE
//// this function checks the value of the comment button selected and calls the presentTrophyComments
//// only call from gesture recognizer on comment label
//-(IBAction)presentTrophyCommentsFromLabel:(id)sender
//{
//    // get superview and affiliated button
//    UILabel *label = sender;
//    TATimelineTableViewCell *parentCell = (TATimelineTableViewCell *)label.superview;
//    
//    TACommentTableViewController *commentVC = [[TACommentTableViewController alloc] initWithPhoto:parentCell.trophy];
//    commentVC.delegate = self;
//    [self.navigationController pushViewController:commentVC animated:YES];
//}

@end
