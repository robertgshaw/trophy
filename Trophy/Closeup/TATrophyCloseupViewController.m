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
//@property (nonatomic, strong) UIButton *commentsButton;
@property (nonatomic, strong) UIButton *moreButton;

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
    
    _moreButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.moreButton.backgroundColor = [UIColor trophyYellowColor];
    [self.moreButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.moreButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    self.moreButton.layer.cornerRadius = 5.0;
    self.moreButton.clipsToBounds = YES;
    [self.moreButton addTarget:self action:@selector(moreButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.moreButton.hidden = YES;
    [self.view addSubview:self.moreButton];

    PFUser *authorObject = [self.trophy.author getUserAsParseObject];

    TAUser *currentUser = [TAActiveUserManager sharedManager].activeUser;
    PFUser *userObject = [currentUser getUserAsParseObject];

    if([authorObject.objectId isEqualToString:userObject.objectId])
    {
        self.moreButton.hidden = NO;
        NSLog(@"HEY");
    }
    
    CGRect frame;
    frame.size = CGSizeMake(60.0, 25.0);
    //frame.origin.x = CGRectGetMidX(self.commentsButton.frame) + 30;
    frame.origin.y = CGRectGetMaxY(self.view.frame) - 140;
    self.moreButton.frame = frame;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake( 0.0f, 0.0f, 52.0f, 32.0f)];
    [backButton setTitle:@"Flag" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithRed:214.0f/255.0f green:210.0f/255.0f blue:197.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [[backButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]]];
    [backButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [backButton addTarget:self action:@selector(flagButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"ButtonBack"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected"] forState:UIControlStateHighlighted];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

#pragma mark - TAOverlayButtonDelegate Methods

- (void) overlayViewDidPressCommentsButton
{
     TACommentTableViewController *commentViewController = [[TACommentTableViewController alloc] initWithPhoto:self.trophy];
    [self.navigationController pushViewController:commentViewController animated:YES];
}

#pragma mark - TACloseupViewDelegate Methods

- (void)closeupViewDidPressCommentsButton:(TATrophyCloseupView *)TrophyCloseupView;
{
    TACommentTableViewController *commentsVC = [[TACommentTableViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:commentsVC];
    [self presentViewController:navController animated:YES completion:nil];
    
    //[self.navigationController pushViewController:commentsVC animated:YES];
    
    //[self.delegate trophyCloseupDidPerformAction:self];
    
}

#pragma mark - TATimelineActionFooterViewDelegate Methods

- (void)didPressLikesButton
{
    [self.delegate trophyCloseupDidPerformAction:self];
    
    //TATrophy *updatedTrophy = [[TATrophyManager sharedManager] likeTrophy:self.trophy];
    //self.trophy = updatedTrophy;
}

- (void)didPressCommentsButton
{
    /*
    TATrophyCloseupViewController *closeupViewController = [[TATrophyCloseupViewController alloc] initWithTrophy:self.trophy];
    closeupViewController.delegate = self;
    [self.navigationController pushViewController:closeupViewController animated:YES];
    */
    
    TACommentTableViewController *commentViewController = [[TACommentTableViewController alloc] initWithPhoto:self.trophy];
    //commentViewController.delegate = self;
    [self.navigationController pushViewController:commentViewController animated:YES];
    //[self.delegate trophyCloseupDidPerformAction:self];
    
}
- (void)flagButtonAction:(id)sender {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Flag"
                                
                                  message:@"Do you want to flag this trophy for removal?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Yes"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             // TODO write FLAG FUNCTION here
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)moreButtonPressed
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
                TATimelineViewController *timelineViewController = [[TATimelineViewController alloc] init];
                
                // delete found objects
                [PFObject deleteAllInBackground:objects];
                NSLog(@"Successfully deleted!");
                [self.navigationController pushViewController:timelineViewController animated:YES];
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];

    }
}
- (void)trophyActionFooterDidPressAddButton
{
    
}

- (void) backButtonPressed
{
    [self.delegate closeUpViewControllerBackButtonPressed];
}
@end
