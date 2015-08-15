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

static const CGFloat kProfileImageWidth = 70.0;
static const CGFloat kProfileImageMargin = 30.0;
static const CGFloat kNameLabelTopMargin = 10.0;
static const CGFloat kLabelPadding = 7.5;
static const CGFloat kLabelInnerMargin = 10.0;

@interface TAProfileHeaderView ()

@property (nonatomic, strong) PFImageView *profileImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *trophiesLabel;
@property (nonatomic, strong) UILabel *groupsLabel;
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
        self.profileImageView.layer.cornerRadius = floorf(kProfileImageWidth / 2.0);
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

        _groupsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.groupsLabel.textAlignment = NSTextAlignmentLeft;
        self.groupsLabel.textColor = [UIColor whiteColor];
        self.groupsLabel.font = [UIFont fontWithName:@"Avenir-Book" size:13.0];
        [self addSubview:self.groupsLabel];
        self.groupsLabel.hidden = YES;
        
        _bioLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.bioLabel.textAlignment = NSTextAlignmentLeft;
        self.bioLabel.textColor = [UIColor whiteColor];
        self.bioLabel.font = [UIFont fontWithName:@"Avenir-Book" size:13.0];
        [self addSubview:self.bioLabel];
        self.groupsLabel.hidden = NO;
        
        _editButton = [[UIButton alloc] initWithFrame:CGRectZero];
        self.editButton.backgroundColor = [UIColor trophyYellowColor];
        [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
        [self.editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.editButton.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        self.editButton.layer.cornerRadius = 5.0;
        self.editButton.clipsToBounds = YES;
        [self.editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.editButton.hidden = YES;
        [self addSubview:self.editButton];
        
        _flagButton = [[UIButton alloc] initWithFrame:CGRectZero];
        self.flagButton.backgroundColor = [UIColor trophyRedColor];
        [self.flagButton setTitle:@"Flag" forState:UIControlStateNormal];
        [self.flagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.flagButton.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
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

    CGRect frame = self.profileImageView.frame;
    frame.origin.x = kProfileImageMargin;
    frame.origin.y = kNameLabelTopMargin;
    frame.size.width = kProfileImageWidth;
    frame.size.height = kProfileImageWidth;
    self.profileImageView.frame = frame;

    self.flagButton.hidden = [self isCurrentUser] == YES;
    [self.flagButton sizeToFit];
    frame = self.flagButton.frame;
    frame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.flagButton.frame) - 2 * kLabelInnerMargin - kProfileImageMargin + 25.0;
    frame.origin.y = CGRectGetMidY(self.profileImageView.frame) - floorf(CGRectGetHeight(self.flagButton.frame) / 2.0);
    frame.size.width = CGRectGetWidth(self.flagButton.frame) + 2 * kLabelInnerMargin;
    self.flagButton.frame = frame;
    
    self.editButton.hidden = [self isCurrentUser] == NO;
    [self.editButton sizeToFit];
    frame = self.editButton.frame;
    frame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.editButton.frame) - 2 * kLabelInnerMargin - kProfileImageMargin;
    frame.origin.y = CGRectGetMidY(self.profileImageView.frame) - floorf(CGRectGetHeight(self.editButton.frame) / 2.0);
    frame.size.width = CGRectGetWidth(self.editButton.frame) + 2 * kLabelInnerMargin;
    self.editButton.frame = frame;
    
    [self.nameLabel sizeToFit];
    CGFloat maxWidth = (self.editButton.hidden ? CGRectGetWidth(self.bounds) - kProfileImageMargin : CGRectGetMinX(self.editButton.frame) - kLabelInnerMargin) - CGRectGetWidth(self.profileImageView.frame) - kProfileImageMargin - kLabelInnerMargin;
    CGSize textSize = CGSizeMake(maxWidth, 150);
    NSDictionary *attributes = @{NSForegroundColorAttributeName:self.nameLabel.textColor,
                                 NSFontAttributeName:self.nameLabel.font};
    CGRect boundRect = [self.nameLabel.text boundingRectWithSize:textSize
                                                                options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                             attributes:attributes
                                                                context:nil];
    frame = self.nameLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.profileImageView.frame) + kLabelInnerMargin;
    frame.origin.y = kNameLabelTopMargin + ([self isCurrentUser] ? 0.0 : 10.0);
    frame.size.width = maxWidth;
    frame.size.height = boundRect.size.height;
    self.nameLabel.frame = frame;

    self.trophiesLabel.hidden = [self.nameLabel.text length] == 0;
    [self.trophiesLabel sizeToFit];
    frame = self.trophiesLabel.frame;
    frame.origin.x = CGRectGetMinX(self.nameLabel.frame);
    frame.origin.y = CGRectGetMaxY(self.nameLabel.frame) + kLabelPadding;
    frame.size.width = maxWidth;
    self.trophiesLabel.frame = frame;

    self.groupsLabel.hidden = [self isCurrentUser] == NO;
    [self.groupsLabel sizeToFit];
    frame = self.groupsLabel.frame;
    frame.origin.x = CGRectGetMinX(self.nameLabel.frame);
    frame.origin.y = CGRectGetMaxY(self.trophiesLabel.frame) + kLabelPadding;
    frame.size.width = maxWidth;
    self.groupsLabel.frame = frame;
    
    self.bioLabel.hidden = [self isCurrentUser] == YES;
    [self.bioLabel sizeToFit];
    frame = self.bioLabel.frame;
    frame.origin.x = CGRectGetMinX(self.nameLabel.frame);
    frame.origin.y = CGRectGetMaxY(self.trophiesLabel.frame) + kLabelPadding;
    frame.size.width = maxWidth;
    self.bioLabel.frame = frame;
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
        [self.groupsLabel setText:@"1 group"];
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
        return [self.groupsLabel.text length] > 0 ? 100.0 : 0.0;
    } else {
        return (self.profileImageView.frame.size.width != 0.0) ? (CGRectGetMaxY(self.profileImageView.frame) + kProfileImageMargin-30) : 0.0;
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
