//
//  TAProfileHeaderView.m
//  Trophy
//
//  Created by Gigster on 1/11/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAProfileHeaderView.h"

#import "TAActiveUserManager.h"

#import "UIColor+TAAdditions.h"
#import <ParseUI/ParseUI.h>

static const CGFloat kProfileImageMargin = 30.0;

@interface TAProfileHeaderView ()

@property (nonatomic, strong) PFImageView *profileImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *trophiesLabel;
@property (nonatomic, strong) UILabel *bioLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *flagButton;

@end


@implementation TAProfileHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor trophyNavyColor];

        _profileImageView = [[PFImageView alloc] init];
        self.profileImageView.backgroundColor = [UIColor whiteColor];
        self.profileImageView.image = [UIImage imageNamed:@"default-profile-icon"];
        self.profileImageView.clipsToBounds = YES;
        [self addSubview:self.profileImageView];

        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16.0];
        [self addSubview:self.nameLabel];

        _trophiesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.trophiesLabel.textAlignment = NSTextAlignmentLeft;
        self.trophiesLabel.textColor = [UIColor whiteColor];
        self.trophiesLabel.font = [UIFont fontWithName:@"Avenir-Book" size:13.0];
        [self addSubview:self.trophiesLabel];
        
        _bioLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.bioLabel.textAlignment = NSTextAlignmentLeft;
        self.bioLabel.textColor = [UIColor whiteColor];
        self.bioLabel.font = [UIFont fontWithName:@"Avenir-Book" size:13.0];
        [self addSubview:self.bioLabel];
        
        _editButton = [[UIButton alloc] initWithFrame:CGRectZero];
        self.editButton.backgroundColor = [UIColor trophyYellowColor];
        [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
        [self.editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.editButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:12.0];
        self.editButton.layer.cornerRadius = 5.0;
        self.editButton.clipsToBounds = YES;
        [self.editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.editButton.hidden = YES;
        [self addSubview:self.editButton];
        
        _flagButton = [[UIButton alloc] initWithFrame:CGRectZero];
        self.flagButton.backgroundColor = [UIColor trophyRedColor];
        [self.flagButton setTitle:@"Flag" forState:UIControlStateNormal];
        [self.flagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.flagButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:12.0];
        self.flagButton.layer.cornerRadius = 5.0;
        self.flagButton.clipsToBounds = YES;
        [self.flagButton addTarget:self action:@selector(flagButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.flagButton.hidden = NO;
        [self addSubview:self.flagButton];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // layout profile image
    CGRect frame = self.profileImageView.frame;
    frame.size.height = self.bounds.size.height * .7;
    frame.size.width = frame.size.height;
    frame.origin.x = self.bounds.size.width * .05;
    frame.origin.y = self.bounds.size.height * .5 - frame.size.height * .5;
    self.profileImageView.frame = frame;
    self.profileImageView.layer.cornerRadius = floorf(frame.size.width / 2.0);
    
    // layout name label
    [self.nameLabel sizeToFit];
    CGFloat maxWidth = CGRectGetMaxX(self.bounds) - CGRectGetMaxX(self.profileImageView.frame)- self.bounds.size.width * .1;
    frame = self.nameLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.profileImageView.frame) + self.bounds.size.width * .03;
    frame.origin.y = self.bounds.size.height * .1;
    frame.size.width = maxWidth;
    self.nameLabel.frame = frame;

    // layout trophies label
    self.trophiesLabel.hidden = [self.nameLabel.text length] == 0;
    [self.trophiesLabel sizeToFit];
    frame = self.trophiesLabel.frame;
    frame.origin.x = self.nameLabel.frame.origin.x;
    frame.origin.y = CGRectGetMaxY(self.nameLabel.frame) + self.bounds.size.height * .075;
    frame.size.width = maxWidth;
    self.trophiesLabel.frame = frame;
    
    // layout bio label
    [self.bioLabel sizeToFit];
    frame = self.bioLabel.frame;
    frame.origin.x = self.nameLabel.frame.origin.x;
    frame.origin.y = CGRectGetMaxY(self.trophiesLabel.frame) + self.bounds.size.height * .075;
    frame.size.width = maxWidth;
    self.bioLabel.frame = frame;
    
    // layout flag button
    self.flagButton.hidden = [self isCurrentUser] == YES;
    [self.flagButton sizeToFit];
    frame = self.flagButton.frame;
    frame.size.width = self.bounds.size.width * .13;
    frame.origin.x = CGRectGetWidth(self.bounds) - frame.size.width - self.bounds.size.width * .06;
    frame.origin.y = CGRectGetMinY(self.bioLabel.frame) - floorf(CGRectGetHeight(self.flagButton.frame) / 2.0);
    self.flagButton.frame = frame;
    
    // layout edit button
    self.editButton.hidden = [self isCurrentUser] == NO;
    self.editButton.frame = self.flagButton.frame;
}

- (void)setUser:(TAUser *)user
{
    _user = user;
    if (_user) {
        PFFile *imageFile = [user parseFileForProfileImage];
        if (imageFile) {
            self.profileImageView.file = imageFile;
            [self.profileImageView loadInBackground];
        }
        
        [self.nameLabel setText:_user.name];
        [self.bioLabel setText:_user.bio];
        [self setNeedsLayout];
    }
}

- (void)setLeaderboardScore:(TALeaderboardScore *)leaderboardScore
{
    _leaderboardScore = leaderboardScore;
    if (_leaderboardScore) {
        if (leaderboardScore.trophyCount > 0) {
            NSString *formatString = (leaderboardScore.trophyCount == 1) ? @"%ld trophy" : @"%ld trophies";
            [self.trophiesLabel setText:[NSString stringWithFormat:formatString, (long)leaderboardScore.trophyCount]];
        } else {
            [self.trophiesLabel setText:@"0 trophies"];
        }
    }
}

- (CGFloat)heightForProfileHeader
{
    if ([self isCurrentUser]) {
        return [self.bioLabel.text length] > 0 ? 100.0 : 0.0;
    } else {
        return (self.profileImageView.frame.size.width != 0.0) ? (CGRectGetMaxY(self.profileImageView.frame) + kProfileImageMargin - 30) : 0.0;
    }
}

- (BOOL)isCurrentUser
{
    return [[TAActiveUserManager sharedManager].activeUser isEqualToUser:self.user];
}

- (void)editButtonPressed:(id)sender
{
    [self.delegate profileHeaderViewDidPressEdit:self];
}
- (void)flagButtonPressed:(id *)sender {
    
    // alert - yes/no for flag
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flag User for Inapporpriate Use" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil]; [alert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) { // Set buttonIndex == 0 to handel "Ok"/"Yes" button response
        // Ok button response
        
        // get trophy author as parse object
        TAUser *user = _user;
        PFUser *authorObject = [user getUserAsParseObject];
        
        // Object method
        PFObject *flag = [PFObject objectWithClassName:@"Flag"];
        flag[@"fromUser"] = [PFUser currentUser];
        flag[@"toUser"] = authorObject;
        flag[@"resolved"] = @NO;
        [flag saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // The object has been saved.
                NSLog(@"Successfully flagged. This user will be reviewed for misbehavior.");
            } else {
                // There was a problem, check error.description
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

@end
