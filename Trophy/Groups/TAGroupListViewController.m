//
//  TAGroupListViewController.m
//  Trophy
//
//  Created by Gigster on 1/21/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAGroupListViewController.h"

#import "TAActiveUserManager.h"
#import "TAAddGroupViewController.h"
#import "TAGroup.h"
#import "TAGroupManager.h"

#import "UIColor+TAAdditions.h"

@interface TAGroupListViewController () <UITableViewDataSource,
                                         UITableViewDelegate,
                                         TACreateGroupViewControllerDelegate,
                                         TAJoinGroupViewControllerDelegate>

@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation TAGroupListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _groups = [TAActiveUserManager sharedManager].activeUser.groups;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"GroupsListCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.groups = [TAActiveUserManager sharedManager].activeUser.groups;
    [self.delegate groupListViewControllerDidReloadGroups:self];
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (CGFloat)heightForList
{
    return ([self.groups count] + 2) * 50.0;
}

#pragma mark - UITableViewDatasource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.groups count] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupsListCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"My Groups";
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Black" size:18.0];
        cell.textLabel.textColor = [UIColor trophyYellowColor];
    } else if (indexPath.row - 1 < [self.groups count]) {
        TAGroup *currentGroup = [self groupAtIndex:(indexPath.row - 1)];
        if (currentGroup) {
            cell.textLabel.text = currentGroup.name;
            // If this is the current group, change background color
            if ([currentGroup.groupId isEqualToString:[TAGroupManager sharedManager].activeGroup.groupId]) {
                cell.backgroundColor = [UIColor trophyYellowColor];
                cell.textLabel.font = [UIFont fontWithName:@"Avenir-Black" size:17.0];
                cell.textLabel.textColor = [UIColor whiteColor];
            } else {
                cell.backgroundColor = [UIColor whiteColor];
                cell.textLabel.font = [UIFont fontWithName:@"Avenir-Black" size:17.0];
                cell.textLabel.textColor = [UIColor trophyYellowColor];
            }
        }
    } else {
        cell.textLabel.text = @"Group Settings";
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Black" size:17.0];
        cell.textLabel.textColor = [UIColor standardBlueButtonColor];
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (TAGroup *)groupAtIndex:(NSInteger)index
{
    id group = self.groups[index];
    if (group == nil) {
        return nil;
    }
    
    TAGroup *currentGroup;
    if ([group isKindOfClass:[TAGroup class]]) {
        currentGroup = group;
    } else if ([group isKindOfClass:[PFObject class]]) {
        currentGroup = [[TAGroup alloc] initWithStoredGroup:group];
    }
    return currentGroup;
}

#pragma mark - UITableViewDelegate Methods

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return NO;
    } else if (indexPath.row - 1 < [self.groups count]){
        TAGroup *group = [self groupAtIndex:(indexPath.row - 1)];
        if ([group.groupId isEqualToString:[TAGroupManager sharedManager].activeGroup.groupId]) {
            return NO;
        }
    }
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == ([self.groups count] + 1)) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        TAAddGroupViewController *addGroupVC = [[TAAddGroupViewController alloc] init];
        addGroupVC.delegate = self;
        [self.navigationController pushViewController:addGroupVC animated:YES];
    } else {
        TAGroup *group = [self groupAtIndex:(indexPath.row - 1)];
        if (group) {
            [[TAGroupManager sharedManager] setActiveGroup:group];
            [self.delegate groupListViewControllerDidChangeGroups:self];
        }
    }
}

#pragma mark - TACreateGroupViewControllerDelegate Methods

- (void)createGroupViewControllerDidCreateGroup:(TACreateGroupViewController *)createGroupViewController
{
    [self.delegate groupListViewControllerDidAddGroup:self];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - TAJoinGroupViewControllerDelegateMethods

- (void)joinGroupViewControllerDidJoinGroup:(TAJoinGroupViewController *)joinGroupViewController
{
    [self.delegate groupListViewControllerDidAddGroup:self];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
