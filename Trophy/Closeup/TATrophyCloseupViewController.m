//
//  TATrophyCloseupViewController.m
//  Trophy
//
//  Created by Gigster on 1/12/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TATrophyCloseupViewController.h"
#import "TACommentTableViewController.h"
#import "TATrophyCloseupView.h"
#import "TAActiveUserManager.h"
#import "UIColor+TAAdditions.h"
#import "TATrophy.h"
#import "TATimelineViewController.h"
#import "TAOverlayButton.h"

@interface TATrophyCloseupViewController () <TALikeButtonDelegate, TAOverlayButtonDelegate, TATrophyCloseupViewDelegate>

@property (nonatomic, strong) TATrophy *trophy;
@property (nonatomic, strong) TATrophyCloseupView *closeupView;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation TATrophyCloseupViewController

- (instancetype)initWithTrophy:(TATrophy *)trophy
{
    self = [super init];
    if (self) {
        _trophy = trophy;
        
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // hides navbar in closeup view
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    
    self.closeupView = [[TATrophyCloseupView alloc] initWithDelegate:self];
    
    [self.closeupView setTrophy:self.trophy];
    self.closeupView.frame = self.view.frame;
    
    [self.view addSubview:self.closeupView];
    
    _deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.deleteButton.backgroundColor = [UIColor trophyYellowColor];
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    self.deleteButton.layer.cornerRadius = 5.0;
    self.deleteButton.clipsToBounds = YES;
    [self.deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.deleteButton.hidden = YES;
    [self.view addSubview:self.deleteButton];

    PFUser *authorObject = [self.trophy.author getUserAsParseObject];

    TAUser *currentUser = [TAActiveUserManager sharedManager].activeUser;
    PFUser *userObject = [currentUser getUserAsParseObject];

    if([authorObject.objectId isEqualToString:userObject.objectId])
    {
        self.deleteButton.hidden = NO;
        NSLog(@"HEY");
    }
    
    CGRect frame;
    frame.size = CGSizeMake(60.0, 25.0);
    frame.origin.x = CGRectGetMaxX(self.view.bounds) - 70;
    frame.origin.y = CGRectGetMinY(self.view.bounds) + 25;
    self.deleteButton.frame = frame;
}

#pragma mark - TAOverlayButtonDelegate Methods

- (void) overlayViewDidPressCommentsButton
{
     TACommentTableViewController *commentViewController = [[TACommentTableViewController alloc] initWithPhoto:self.trophy];
    [self.navigationController pushViewController:commentViewController animated:YES];
}

#pragma mark - TACloseupViewDelegate Methods

- (void)closeupViewDidPressCommentsButton:(TATrophyCloseupView *)TrophyCloseupView
{
    TACommentTableViewController *commentsVC = [[TACommentTableViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:commentsVC];
    [self presentViewController:navController animated:YES completion:nil];

}

#pragma mark - TALikesButtonDelegate Methods
-(void) likesButtonDidPressLikesButton:(TATrophy *)updatedTrophy
{
    NSLog(@"yoooo");
    [self.delegate trophyCloseupDidPerformAction:self];
}

- (void)deleteButtonPressed
{
    // alert - yes/no for delete
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Trophy" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil]; [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) { // Set buttonIndex == 0 to handel "Ok"/"Yes" button response
        // Ok button response
        PFQuery *query = [PFQuery queryWithClassName:@"Trophy"];
        [query whereKey:@"objectId" equalTo: [self.trophy getTrophyAsParseObject].objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                
                //init timeline to take user back to timeline after trophy is deleted
                //TATimelineViewController *timelineViewController = [[TATimelineViewController alloc] init];
                
                // delete found objects
                [PFObject deleteAllInBackground:objects];
                NSLog(@"Successfully deleted!");
                //[self.navigationController pushViewController:timelineViewController animated:YES];
                //self.navigationController.navigationBarHidden = NO;
                [self.delegate closeUpViewControllerBackButtonPressed];

                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];

    }
}

- (void) backButtonPressed
{
    [self.delegate closeUpViewControllerBackButtonPressed];
}
@end
