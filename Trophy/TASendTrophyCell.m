//
//  TASendTrophyCell.m
//  Trophy
//
//  Created by Robert Shaw on 8/10/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TASendTrophyCell.h"
#import <ParseUI/ParseUI.h>

static const CGFloat kProfileImageWidth = 90.0;
static const CGFloat cellMargin = 5.0;
static const CGFloat cellMarginLeft = 20.0;

@interface TASendTrophyCell ()

@end

@implementation TASendTrophyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.backgroundView = [[UIView alloc] init];
        [self.backgroundView setBackgroundColor:[UIColor clearColor]];
        
        // configures profile image
        _profileImageView = [[PFImageView alloc] init];
        self.profileImageView.backgroundColor = [UIColor whiteColor];
        self.profileImageView.image = [UIImage imageNamed:@"default-profile-icon"];
        self.profileImageView.layer.cornerRadius = floorf(kProfileImageWidth / 2.0);
        self.profileImageView.clipsToBounds = YES;
        [self addSubview:self.profileImageView];
        
        // configures mame label
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [UIColor darkGrayColor];
        self.nameLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:22.0];
        [self addSubview:self.nameLabel];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect frame = self.profileImageView.frame;
    frame.origin.x = cellMarginLeft;
    frame.origin.y = cellMargin;
    frame.size.width = kProfileImageWidth;
    frame.size.height = kProfileImageWidth;
    self.profileImageView.frame = frame;
    
    [self.nameLabel sizeToFit];
    frame = self.nameLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.profileImageView.frame) + 25.0;
    frame.origin.y = cellMargin;
    frame.size.height = self.profileImageView.frame.size.height;
    self.nameLabel.frame = frame;

}

//// overrides get method to configure timeline cell
//- (void)setUser:(PFUser *)user
//{
//    _user = user;
//    
//    // gets users profile image for the cell, loads in background
//    if (self.user) {
//        if (self.user[@"profileImage"]) {
//            self.profileImageView.file = self.user[@"profileImage"];
//            [self.profileImageView  loadInBackground];
//        }
//    }
//    
//    // gets users names for the cell
//    [self.nameLabel setText:_user[@"name"]];
//    
//    // calls for the cell to be reloaded
//    [self setNeedsLayout];
//}

+ (CGFloat)heightOfCell
{
    return kProfileImageWidth + 2 * cellMargin;
}

@end
