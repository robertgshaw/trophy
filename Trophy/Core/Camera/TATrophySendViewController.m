//
//  TATrophySendViewController.m
//  Trophy
//
//  Created by Gigster on 1/8/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TATrophySendViewController.h"

#import "TAActiveUserManager.h"
#import "TAGroupManager.h"
#import "UIColor+TAAdditions.h"

@interface TATrophySendViewController () <UITableViewDataSource,
                                          UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSIndexPath *selectedPath;

@end

@implementation TATrophySendViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor trophyYellowColor];
    
    self.navigationItem.title = @"Award to...";
    self.navigationItem.titleView.tintColor = [UIColor whiteColor];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"send-back-button"] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed)];
    leftButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftButton;

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendButtonPressed)];
    rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    [[TAGroupManager sharedManager] getUsersForActiveGroupWithSuccess:^(NSArray *users) {
        self.users = users;
        [self.tableView reloadData];
    } failure:^(NSString *error) {
        NSLog(@"%@", error);
    }];
}

- (void)closeButtonPressed
{
    [self.delegate trophySendViewControllerDidPressClose];
}

- (void)sendButtonPressed
{
    if (self.selectedPath) {
        PFUser *user = self.users[self.selectedPath.row];
        TAUser *selectedUser = [[TAUser alloc] initWithStoredUser:user];
        [self.delegate trophySendViewControllerDidPressSend:selectedUser];
    }
}

#pragma mark - UITableView Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    cell.backgroundView = [[UIView alloc] init];
    [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
    [[[cell contentView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    PFUser *user = self.users[indexPath.row];
    
        if ([user.username isEqualToString:[TAActiveUserManager sharedManager].activeUser.username]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ (Me)", user[@"name"]];
        } else {
            cell.textLabel.text = user[@"name"];
        }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath == self.selectedPath) {
        self.selectedPath = nil;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        if (self.selectedPath != nil) {
            [tableView deselectRowAtIndexPath:self.selectedPath animated:YES];
        }
        self.selectedPath = indexPath;
        if (self.navigationItem.rightBarButtonItem.enabled == NO) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
}


@end
