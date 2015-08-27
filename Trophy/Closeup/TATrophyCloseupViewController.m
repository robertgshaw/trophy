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
#import "TAFlagButton.h"
#import "TAGroupManager.h"

static const CGFloat closeupMargin = 3;

@interface TATrophyCloseupViewController () <TACommentTableViewControllerDelegate, TAFlagButtonDelegate, TABackButtonDelegate, TALikeButtonDelegate, TAOverlayButtonDelegate, TATrophyCloseupViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) TATrophy *trophy;
@property (nonatomic, strong) TATrophyCloseupView *closeupView;
@property (nonatomic, strong) UIButton *deleteButton;
@property BOOL isAbleToBeDeleted;

@end

@implementation TATrophyCloseupViewController

- (instancetype)initWithTrophy:(TATrophy *)trophy
{
    self = [super init];
    if (self) {
        self.trophy = trophy;
        
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // hides navbar in closeup view
    self.navigationController.navigationBarHidden = YES;

    self.view.backgroundColor = [UIColor blackColor];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;

    // configures and adds closeup view
    self.closeupView = [[TATrophyCloseupView alloc] initWithDelegate:self];
    [self.closeupView setTrophy:self.trophy];
    self.closeupView.frame = self.view.frame;
    [self.view addSubview:self.closeupView];
    
    // configures and adds delete button
    _deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.deleteButton setBackgroundImage:[UIImage imageNamed:@"delete-icon"] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.deleteButton.hidden = YES;
    self.isAbleToBeDeleted = NO;
    self.closeupView.deleteButton = self.deleteButton;
    [self.closeupView addSubview:self.deleteButton];

    PFUser *authorObject = [self.trophy.author getUserAsParseObject];
    
    TAUser *currentUser = [TAActiveUserManager sharedManager].activeUser;
    PFUser *userObject = [currentUser getUserAsParseObject];

    if([authorObject.objectId isEqualToString:userObject.objectId])
    {
        self.deleteButton.hidden = NO;
        self.isAbleToBeDeleted = YES;
    }
}

#pragma mark - TAOverlayButtonDelegate Methods

- (void) overlayViewDidPressCommentsButton
{
    TACommentTableViewController *commentViewController = [[TACommentTableViewController alloc] initWithPhoto:self.trophy];
    commentViewController.delegate = self;
    [self.navigationController pushViewController:commentViewController animated:YES];
}

#pragma mark - TACloseupViewDelegate Methods

- (void)closeupViewDidPressCommentsButton:(TATrophyCloseupView *)TrophyCloseupView
{
    TACommentTableViewController *commentViewController = [[TACommentTableViewController alloc] initWithPhoto:self.trophy];
    commentViewController.delegate = self;
    [self.navigationController pushViewController:commentViewController animated:YES];
}

// on background tap, hide the labels, etc
- (void)hideDisplays
{
    [self.closeupView hideOverlay];
    self.closeupView.backButton.hidden = !self.closeupView.backButton.hidden;
    self.closeupView.flagButton.hidden = !self.closeupView.flagButton.hidden;
    self.closeupView.commentsButton.hidden = !self.closeupView.commentsButton.hidden;
    self.closeupView.dateLabel.hidden = !self.closeupView.dateLabel.hidden;
    self.closeupView.likesButton.hidden = !self.closeupView.likesButton.hidden;
    
    // only toggle delete button if user is author of image
    if (self.isAbleToBeDeleted) {
        self.deleteButton.hidden = !self.deleteButton.hidden;
    }
}

#pragma mark - TALikesButtonDelegate Methods

-(void) likesButtonDidPressLikesButton:(TATrophy *)updatedTrophy
{
    [self.delegate trophyCloseupDidPerformAction:updatedTrophy];
}


#pragma - DeleteButton Action Handler

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
                
                // delete found objects
                [PFObject deleteAllInBackground:objects];
                
                // decrement trophy count
                PFQuery *groupQuery = [PFQuery queryWithClassName:@"LeaderboardScore"];
                [groupQuery whereKey:@"groupId" equalTo:[TAGroupManager sharedManager].activeGroup.groupId];
                
                PFQuery *userQuery = [PFQuery queryWithClassName:@"LeaderboardScore"];
                PFUser *recipientObject = [PFUser objectWithoutDataWithClassName:@"User" objectId:[self.trophy.recipient getUserAsParseObject].objectId];
                [userQuery whereKey:@"user" equalTo:recipientObject];
                
                PFQuery *mainQuery = [PFQuery orQueryWithSubqueries:@[groupQuery,userQuery]];
                [mainQuery getFirstObjectInBackgroundWithBlock:^(PFObject *results, NSError *error1) {
                    if (!error1){
                        // found group and user
                        NSNumber *dec = [NSNumber numberWithInt:-1];
                        [results incrementKey:@"trophyCount" byAmount:dec];
                        [results saveInBackground];
                    } else {
                        //log details of failure
                        NSLog(@"Error Trophy count: %@ %@", error1, [error1 userInfo]);
                    }
                }];
                
                NSLog(@"Successfully deleted!");
                
                [self.delegate closeUpViewControllerBackButtonPressed];

            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];

    }
}

#pragma mark - TACommentTableViewDelegate Methods

- (void) trophyCommentDidPerformAction:(TATrophy *)updatedTrophy
{
    [self.delegate trophyCloseupDidPerformAction:updatedTrophy];
}

- (void) trophyCommentViewControllerDidPressBackButton
{
    [self.navigationController popToViewController:self animated:YES];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - TABackButtonDelegate Methods

- (void)backButtonDidPressBack
{
    [self.delegate closeUpViewControllerBackButtonPressed];
}

#pragma mark - TAFlagButtonDelegate Methods

// gives flag button access to trophy property
- (TATrophy *)getTATrophy
{
    return self.trophy;
}

#pragma mark - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.closeupView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
}

@end
