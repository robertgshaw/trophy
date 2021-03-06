//
//  TASettingsView.m
//  Trophy
//
//  Created by Gigster on 1/1/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TASettingsView.h"

#import "UIColor+TAAdditions.h"
#import "UITextField+TAAdditions.h"
#import <ParseUI/ParseUI.h>
#import "TAActiveUserManager.h"
#import "TASignupViewController.h"

static const CGFloat kTextFieldWidth = 200.0;

@interface TASettingsView ()<UITextFieldDelegate>

@property (nonatomic, strong) NSString *originalName;
@property (nonatomic, strong) NSString *originalBio;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *bioLabel;
@property (nonatomic, strong) UIButton *profileImageButton;
@property (nonatomic, strong) PFImageView *profileImageView;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *deleteProfileButton;
@property (nonatomic, strong) UITextField *nameInput;
@property (nonatomic, strong) UITextField *descriptionInput;
@property (nonatomic, assign) BOOL imageHasChanged;

@end

@implementation TASettingsView

- (instancetype)initWithSettings:(TAUser *)user
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor trophyNavyColor];
        self.originalName = user.name;
        self.originalBio = user.bio;
        self.originalImage = user.profileImage;

        _nameLabel = [[UILabel alloc] init];
        self.nameLabel.text = @"Name";
        self.nameLabel.font = [UIFont fontWithName:@"Avenir-Book" size:16.0];
        self.nameLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.nameLabel];

        _nameInput = [TATextField textFieldTranslucent];
        self.nameInput.delegate = self;
        self.nameInput.placeholder = @"Name";
        self.nameInput.font = [UIFont fontWithName:@"Avenir" size:15.0];
        self.nameInput.textColor = [UIColor trophyNavyColor];
        self.nameInput.text = user.name;
        self.nameInput.backgroundColor = [UIColor whiteColor];
        self.nameInput.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.nameInput.returnKeyType = UIReturnKeyNext;
        [self addSubview:self.nameInput];

        _bioLabel = [[UILabel alloc] init];
        self.bioLabel.text = @"College";
        self.bioLabel.font = [UIFont fontWithName:@"Avenir" size:15.0];
        self.bioLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.bioLabel];

        _descriptionInput = [TATextField textFieldTranslucent];
        self.descriptionInput.delegate = self;
        self.descriptionInput.placeholder = @"College";
        self.descriptionInput.font = [UIFont fontWithName:@"Avenir" size:15.0];
        self.descriptionInput.textColor = [UIColor trophyNavyColor];
        self.descriptionInput.text = user.bio;
        self.descriptionInput.backgroundColor = [UIColor whiteColor];
        self.descriptionInput.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        self.descriptionInput.returnKeyType = UIReturnKeyDone;
        [self addSubview:self.descriptionInput];
        

        _profileImageButton = [[UIButton alloc] init];
        //self.profileImageButton.layer.borderWidth = 3.0f;
        //self.profileImageButton.layer.borderColor = [UIColor trophyYellowColor].CGColor;
        self.profileImageButton.clipsToBounds = YES;
        [self.profileImageButton addTarget:self action:@selector(profileImageButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.profileImageButton];
        
        PFFile *imageFile = [user parseFileForProfileImage];
        if (imageFile) {
            _profileImageView = [[PFImageView alloc] init];
            self.profileImageView.file = imageFile;
            [self.profileImageView loadInBackground];
            [self.profileImageButton addSubview:self.profileImageView];
        } else {
            [self.profileImageButton setBackgroundImage:[UIImage imageNamed:@"create-profile-placeholder"] forState:UIControlStateNormal];
        }

        _saveButton = [[UIButton alloc] init];
        [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
        [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.saveButton.backgroundColor = [UIColor darkerBlueColor];
        [self.saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.saveButton.layer.cornerRadius = 5.0;
        self.saveButton.font = [UIFont fontWithName:@"Avenir-Heavy" size:18.0];
        self.saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:self.saveButton];
        self.saveButton.enabled = NO;
        
        _deleteProfileButton = [[UIButton alloc] init];
        [self.deleteProfileButton setTitle:@"Delete Profile" forState:UIControlStateNormal];
        [self.deleteProfileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.deleteProfileButton.backgroundColor = [UIColor trophyRedColor];
        [self.deleteProfileButton addTarget:self action:@selector(deleteProfileButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.deleteProfileButton.font = [UIFont fontWithName:@"Avenir-Heavy" size:14.0];

        self.deleteProfileButton.layer.cornerRadius = 5.0;
        self.deleteProfileButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:self.deleteProfileButton];
        self.deleteProfileButton.enabled = YES;

        self.imageHasChanged = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    // constants
    CGFloat superWidth = self.bounds.size.width;
    CGFloat superHeight = self.bounds.size.height;
    CGFloat margin = superWidth * .1;
    CGFloat space = superHeight * .055;

    // name label
    [self.nameLabel sizeToFit];
    CGRect frame = self.nameLabel.frame;
    frame.origin.x = margin;
    frame.origin.y = margin;
    self.nameLabel.frame = frame;

    // name input
    frame = self.nameInput.frame;
    frame.origin.x = CGRectGetMaxX(self.nameLabel.frame) + 20.0;
    frame.size.width = superWidth - margin - frame.origin.x;
    frame.size.height = self.bounds.size.height * .075;
    frame.origin.y = CGRectGetMidY(self.nameLabel.frame) - (frame.size.height / 2);
    self.nameInput.frame = frame;

    // bio label
    [self.bioLabel sizeToFit];
    frame = self.bioLabel.frame;
    frame.origin.x = self.nameLabel.frame.origin.x;
    frame.origin.y = CGRectGetMaxY(self.nameInput.frame) + space;
    self.bioLabel.frame = frame;

    // description input
    frame = self.descriptionInput.frame;
    frame.origin.x = self.nameInput.frame.origin.x;
    frame.size.width = self.nameInput.frame.size.width;
    frame.size.height = self.nameInput.frame.size.height;
    frame.origin.y = CGRectGetMidY(self.bioLabel.frame) - (frame.size.height / 2);
    self.descriptionInput.frame = frame;

    // profile image button
    frame = self.profileImageButton.frame;
    frame.size.width = superWidth * .5;
    frame.size.height = frame.size.width;
    frame.origin.x = floorf(CGRectGetMidX(self.bounds) - (frame.size.width / 2.0));
    frame.origin.y = CGRectGetMaxY(self.descriptionInput.frame) + margin;
    self.profileImageButton.frame = frame;
    self.profileImageButton.layer.cornerRadius = floorf(CGRectGetWidth(self.profileImageButton.frame) / 2.0);
    self.profileImageView.frame = self.profileImageButton.bounds;
    
    // save button
    [self.saveButton sizeToFit];
    frame = self.saveButton.frame;
    frame.size.width = superWidth * .3;
    frame.size.height = superHeight * .06;
    frame.origin.x = floorf(CGRectGetMidX(self.bounds) - (frame.size.width / 2.0));
    frame.origin.y = CGRectGetMaxY(self.profileImageButton.frame) + space / 2;
    self.saveButton.frame = frame;
    
    // delete profile button
    [self.deleteProfileButton sizeToFit];
    frame = self.deleteProfileButton.frame;
    frame.size.width = superWidth * .3;
    frame.size.height = superHeight * .06;
    frame.origin.x = floorf(CGRectGetMidX(self.bounds) - (frame.size.width / 2.0));
    frame.origin.y = CGRectGetMaxY(self.saveButton.frame) + space / 2;
    self.deleteProfileButton.frame = frame;
}

- (void)setProfileImage:(UIImage *)profileImage
{
    if (profileImage) {
        [self.profileImageButton setBackgroundImage:profileImage forState:UIControlStateNormal];
        [self.profileImageButton setTitle:@"" forState:UIControlStateNormal];
        [self.profileImageView removeFromSuperview];
        self.imageHasChanged = YES;
        [self enableSaveButton];
    }
    _profileImage = profileImage;
}

+ (CGFloat)profileImageWidth
{
    return kTextFieldWidth;
}

#pragma mark - Private Methods

- (void)profileImageButtonPressed
{
    [self.delegate settingsViewDidPressProfileImageButton:self];
}

- (void)saveButtonPressed
{
    [self.delegate settingsViewDidPressSaveButton:self];
}
- (void)deleteProfileButtonPressed
{
    // alert - yes/no for flag
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Profile?" message:@"You cannot undo this action." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil]; [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) { // Set buttonIndex == 0 to handel "Ok"/"Yes" button response
        // Ok button response
        
        //Get user information
        TAUser *currentUser = [TAActiveUserManager sharedManager].activeUser;
        PFUser *userObject = [currentUser getUserAsParseObject];
        PFUser *authorObject = [PFUser objectWithoutDataWithClassName:@"User" objectId:userObject.objectId];
        
        //TODO delete from leaderboard
        PFQuery *leadQuery = [PFQuery queryWithClassName:@"LeaderboardScore"];
        [leadQuery whereKey:@"user" equalTo:authorObject];
        [leadQuery findObjectsInBackgroundWithBlock:^(NSArray *leadObjects, NSError *error1) {
            if (!error1) {
                // The find succeeded.
                NSLog(@"Successfully deleted %d leaderboard users.", leadObjects.count);
                // Do something with the found objects
                [PFObject deleteAllInBackground:leadObjects];
                
                
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error1, [error1 userInfo]);
            }
        }];
        
        
        //Query parse
        PFQuery *query = [PFQuery queryWithClassName:@"User"];
        //Match User with current user to delete
        [query whereKey:@"objectId" equalTo: userObject.objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                
                
                // The find succeeded delete found objects
                [[PFUser currentUser] deleteInBackground];
                
                // delete from leaderboard
                
                PFQuery *leaderQuery = [PFQuery queryWithClassName:@"LeaderboardScore"];
                [leaderQuery whereKey:@"user" equalTo:userObject.objectId];
                PFObject *leaderObj = [leaderQuery getObjectWithId:userObject.objectId];
                PFObject *leaderObj1 = [leaderQuery getFirstObject];
                [leaderObj deleteInBackground];
                [leaderObj1 deleteInBackground];
                
                
                
                
                
                //TODO delete from group array
                
                
                NSLog(@"Successfully deleted!");
                
                //end session
                [[TAActiveUserManager sharedManager] endSession];
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    }
}
- (void)enableSaveButton
{
    if ([self.name isEqualToString:self.originalName] == NO ||
        [self.bio isEqualToString:self.originalBio] == NO ||
        self.imageHasChanged) {
            self.saveButton.enabled = YES;
            self.saveButton.backgroundColor = [UIColor standardBlueButtonColor];
    } else {
        self.saveButton.enabled = NO;
        self.saveButton.backgroundColor = [UIColor unselectedGrayColor];
    }
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameInput) {
        [self.descriptionInput becomeFirstResponder];
    } else {
        [self.descriptionInput resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.nameInput) {
        self.name = newString;
    } else if (textField == self.descriptionInput) {
        self.bio = newString;
    }
    [self enableSaveButton];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView *view in self.subviews){
        if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder]) {
            [view resignFirstResponder];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.nameInput) {
        self.nameInput.backgroundColor = [UIColor whiteColor];
    } else if (textField == self.descriptionInput) {
        self.descriptionInput.backgroundColor = [UIColor whiteColor];
    }
    return YES;
}

- (NSString *)name
{
    return self.nameInput.text;
}

- (NSString *)bio
{
    return self.descriptionInput.text;
}

@end
