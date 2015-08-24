//
//  TACommentTableViewController.m
//  Trophy
//
//  Created by Kenny Okagaki on 6/25/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TACommentTableViewController.h"
#import "TACommentActivityTableViewCell.h"
#import "TACommentBaseTableViewCell.h"
#import "TATrophyCloseupView.h"
#import "TATrophyCloseupViewController.h"
#import "TATimelineViewController.h"
#import "TACommentLoadMoreTableViewCell.h"
#import "TAPhotoDetailsFooterView.h"
#import "TAActiveUserManager.h"
#import "MBProgressHUD.h"

enum ActionSheetTags {
    MainActionSheetTag = 0,
    ConfirmDeleteActionSheetTag = 1
};

@interface TACommentTableViewController ()
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) TATrophy *trophy;

@end

static const CGFloat kPAPCellInsetWidth = 20.0f;

@implementation TACommentTableViewController

@synthesize commentTextField;

#pragma mark - Initialization

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
- (id)initWithPhoto:(TATrophy *)trophy {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _trophy = trophy;
        self.photo = [trophy getTrophyAsParseObject];
        
        // Set query table view properties
        self.parseClassName = @"Activity";
        self.objectsPerPage = 10;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [super viewDidLoad];
    
    [self.navigationItem setHidesBackButton:NO];
    self.navigationController.navigationBarHidden = NO;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake( 0.0f, 0.0f, 52.0f, 32.0f)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.tintColor = [UIColor whiteColor];
    [[backButton titleLabel] setFont:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]]];
    [backButton setTitleEdgeInsets:UIEdgeInsetsMake( 0.0f, 5.0f, 0.0f, 0.0f)];
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundImage:[UIImage imageNamed:@"ButtonBack"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"ButtonBackSelected"] forState:UIControlStateHighlighted];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    

     // Set table view properties
     UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
     [texturedBackgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather"]]];
     self.tableView.backgroundView = texturedBackgroundView;
    
    //set footer
    TAPhotoDetailsFooterView *footerView = [[TAPhotoDetailsFooterView alloc] initWithFrame:[TAPhotoDetailsFooterView rectForView]];
    commentTextField = footerView.commentField;
    [commentTextField setDelegate:self];
    self.tableView.tableFooterView = footerView;
    
    // Register to be notified when the keyboard will be shown to scroll the view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) { // A comment row
        
        //PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        
        NSString *commentString  = [[self.objects objectAtIndex:indexPath.row] objectForKey:@"content"];
        NSString *nameString = @"";
        
        return [TACommentActivityTableViewCell heightForCellWithName:nameString contentString:commentString cellInsetWidth:kPAPCellInsetWidth];
    } else { // The pagination row
        return 44.0f;
    }
}
#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    [query whereKey:@"trophy" equalTo:self.photo];
    [query whereKey:@"type" equalTo:@"comment"];
    [query includeKey:@"author"];
    [query orderByAscending:@"createdAt"];
    
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    return query;
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *cellID = @"commentCell";
    
    // Try to dequeue a cell and create one if necessary
    TACommentBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[TACommentBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        [cell setCellInsetWidth:kPAPCellInsetWidth];
        [cell setDelegate:self];
    }
    [cell setUser:[object objectForKey:@"author"]];
    [cell setContentText:[object objectForKey:@"content"]];
    [cell setDate:[object createdAt]];
    
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPage";
    
    TACommentLoadMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TACommentLoadMoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.hideSeparatorTop = YES;
    }
    
    return cell;
}
// is this necessary hmm

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    // trim comment text
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (trimmedComment.length != 0 && [self.photo objectForKey:@"author"]) {
        
        // Set comment function
        PFObject *comment = [PFObject objectWithClassName:@"Activity"];
        [comment setValue:trimmedComment forKey:@"content"]; // Set comment text
        //[comment setValue:_trophy.author forKey:@"recipient"]; // Set toUser
        [comment setValue:[PFUser currentUser] forKey:@"author"]; // Set fromUser
        [comment setValue:@"comment" forKey:@"type"];
        [comment setValue:[self.trophy getTrophyAsParseObject] forKey:@"trophy"];
        
//        // Update comment count on trophy, asynchronously - in Parse
//        PFQuery *trophy = [PFQuery queryWithClassName:@"Trophy"];
//        [trophy getObjectInBackgroundWithId:[self.trophy getTrophyAsParseObject].objectId
//                                     block:^(PFObject *counter, NSError *error) {
//                                         
//                                         // update counter, synchronously, so that timeline updates correclty
//                                         [counter incrementKey:@"commentNumber" byAmount:[NSNumber numberWithInt:1]];
//                                         [counter save];
//                                         NSLog(@"here");
//                                         
////                                          // update counter, asychronously
////                                         [counter incrementKey:@"commentNumber" byAmount:[NSNumber numberWithInt:1]];
////                                         [counter saveInBackground];
//                                         
//                                         // update comment count on trophy - on local Trophy model
//                                         [self.trophy updateCommentNumber];
//                                     }];
        
        // Update comment count on trophy, synchronously, to update timeline - in Parse
        PFQuery *trophy = [PFQuery queryWithClassName:@"Trophy"];
        PFObject *counter = [trophy getObjectWithId:[self.trophy getTrophyAsParseObject].objectId];
        [counter incrementKey:@"commentNumber" byAmount:[NSNumber numberWithInt:1]];
        [counter save];
        
        [self.trophy updateCommentNumber];
        
        //update ACL
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        comment.ACL = ACL;
        
        //[[PAPCache sharedCache] incrementCommentCountForPhoto:self.photo];
        
        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
        
        // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:[NSDictionary dictionaryWithObject:comment forKey:@"comment"] repeats:NO];
        
        [comment saveEventually:^(BOOL succeeded, NSError *error) {
            [timer invalidate];
            
            if (error && [error code] == kPFErrorObjectNotFound) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not post comment" message:@"This photo was deleted by its owner" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                /*
                 // TODO CHANGE IF WE WANT PUSH NOTIFS FOR COMMENTS
                 // refresh cache
                 
                 NSMutableSet *channelSet = [NSMutableSet setWithCapacity:self.objects.count];
                 
                 // set up this push notification to be sent to all commenters, excluding the current  user
                 for (PFObject *comment in self.objects) {
                 PFUser *author = [comment objectForKey:@"author"];
                 NSString *privateChannelName = [author objectForKey:kPAPUserPrivateChannelKey];
                 if (privateChannelName && privateChannelName.length != 0 && ![[author objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                 [channelSet addObject:privateChannelName];
                 }
                 }
                 [channelSet addObject:[self.photo objectForKey:kPAPPhotoUserKey]];
                 
                 if (channelSet.count > 0) {
                 NSString *alert = [NSString stringWithFormat:@"%@: %@", [PAPUtility firstNameForDisplayName:[[PFUser currentUser] objectForKey:kPAPUserDisplayNameKey]], trimmedComment];
                 
                 // make sure to leave enough space for payload overhead
                 if (alert.length > 100) {
                 alert = [alert substringToIndex:99];
                 alert = [alert stringByAppendingString:@"…"];
                 }
                 
                 NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                 alert, kAPNSAlertKey,
                 kPAPPushPayloadPayloadTypeActivityKey, kPAPPushPayloadPayloadTypeKey,
                 kPAPPushPayloadActivityCommentKey, kPAPPushPayloadActivityTypeKey,
                 [[PFUser currentUser] objectId], kPAPPushPayloadFromUserObjectIdKey,
                 [self.photo objectId], kPAPPushPayloadPhotoObjectIdKey,
                 @"Increment",kAPNSBadgeKey,
                 nil];
                 PFPush *push = [[PFPush alloc] init];
                 [push setChannels:[channelSet allObjects]];
                 [push setData:data];
                 [push sendPushInBackground];
                 }
                 */
            }
            
             // TODO CHANGE IF WE WANT PUSH NOTIFS FOR COMMENTS
            /*
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.parse.Anypic.photoDetailsViewController.userCommentedOnPhotoInDetailsViewNotification" object:self.photo userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.objects.count + 1] forKey:@"comments"]];
             */
            
            // on success, reload comments in the comment view
            [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self loadObjects];
            
            // on success, tell timeline of updated trophy
            [self.delegate trophyCommentDidPerformAction:self.trophy];
            
        }];
    }
    [textField setText:@""];
    return [textField resignFirstResponder];
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == MainActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this photo?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Yes, delete photo" otherButtonTitles:nil];
            actionSheet.tag = ConfirmDeleteActionSheetTag;
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        }
    } else if (actionSheet.tag == ConfirmDeleteActionSheetTag) {
        if ([actionSheet destructiveButtonIndex] == buttonIndex) {
            
            /*
             // TODO CHANGE IF WE WANT PUSH NOTIFS FOR COMMENTS
             [[NSNotificationCenter defaultCenter] postNotificationName:PAPPhotoDetailsViewControllerUserDeletedPhotoNotification object:[self.photo objectId]];
             */
            
            // Delete all activites related to this photo
            PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
            [query whereKey:@"trophy" equalTo:self.photo];
            [query findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
                if (!error) {
                    for (PFObject *activity in activities) {
                        [activity deleteEventually];
                    }
                }
                
                // Delete photo
                [self.photo deleteEventually];
            }];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [commentTextField resignFirstResponder];
}

#pragma mark - PAPBaseTextCellDelegate
//TODO CHANGE FOR PRESSING PROFILE OF PERSON WHO COMMENTS
/*
 - (void)cell:(TACommentBaseTableViewCell *)cellView didTapUserButton:(PFUser *)aUser {
 [self shouldPresentAccountViewForUser:aUser];
 }
 */

- (void)actionButtonAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photo" otherButtonTitles:nil];
    actionSheet.tag = MainActionSheetTag;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - ()

- (void)handleCommentTimeout:(NSTimer *)aTimer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Comment" message:@"Your comment will be posted next time there is an Internet connection."  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
    [alert show];
}

- (void)backButtonAction:(id)sender {
    
//    UINavigationController *navController = self.navigationController;
//    
//    [navController popViewControllerAnimated:YES];
//    
//    navController.navigationBarHidden = YES;
    [self.delegate trophyCommentViewControllerDidPressBackButton];
    
}

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-kbSize.height) animated:YES];
}


@end
