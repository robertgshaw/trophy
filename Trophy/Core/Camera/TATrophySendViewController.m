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
#import "TASendTrophyCell.h"

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
    
    //change top bar icon collor
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.barTintColor = [UIColor darkYellowColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"Award To...";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;

    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"send-back-button"] style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed)];
    leftButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftButton;

    _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

# pragma mark - UIAlertView methods

- (void) userCellPressedAt:(NSIndexPath *) indexPath {

    NSString *title;
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    
    // checks, typecasts cell to TASendTrophyCell
    if ([cell isKindOfClass:[TASendTrophyCell class]]) {
        title = [NSString stringWithFormat:@"Award Trophy To %@?", ((TASendTrophyCell *) cell).user[@"name"]];
    } else {
        title = @"Award Trophy To User?";
    }
    
    // alert - yes/ no to send trophy
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil]; [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) { // Set buttonIndex == 0 to handel "Ok"/"Yes" button response
        
        [self sendButtonPressed];
    }
}


#pragma mark - UITableView Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.users count];
}

// adds TASendTrophyCells to the table view
- (TASendTrophyCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";

    TASendTrophyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TASendTrophyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    [[[cell contentView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    // gets the correct user
    PFUser *user = self.users[indexPath.row];
    
    // initializes the cell's properties
    cell.user = user;
    
    // initializes the name label
    if ([user.username isEqualToString:[TAActiveUserManager sharedManager].activeUser.username]) {
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ (Me)", user[@"name"]];
    } else {
        cell.nameLabel.text = user[@"name"];
    }
    
    // initializes and loads the profile image
    if (user[@"profileImage"]) {
        cell.profileImageView.file = user[@"profileImage"];
        [cell.profileImageView loadInBackground];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TASendTrophyCell heightOfCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath == self.selectedPath) {
        self.selectedPath = nil;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        if (self.selectedPath != nil) {
            [tableView deselectRowAtIndexPath:self.selectedPath animated:YES];
        }
        self.selectedPath = indexPath;
    }
    
    [self userCellPressedAt:indexPath];

}


@end
