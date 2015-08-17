//
//  TALeaderboardTableViewCell.m
//  Trophy
//
//  Created by Gigster on 2/15/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TALeaderboardTableViewCell.h"

#import "TAUser.h"

#import "UIColor+TAAdditions.h"
#import <ParseUI/ParseUI.h>

static const CGFloat kCellProfileImageWidth = 50.0;
static const CGFloat kCellSideMargin = 20.0;
static const CGFloat kCellInnerMargin = 10.0;

@interface TALeaderboardTableViewCell ()

@property (nonatomic, strong) PFImageView *profileImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *trophyCountLabel;
@property (nonatomic, strong) UILabel *rankLabel;

@end

@implementation TALeaderboardTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _profileImageView = [[PFImageView alloc] init];
        self.profileImageView.layer.cornerRadius = floorf(kCellProfileImageWidth / 2.0);
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImageView.clipsToBounds = YES;
        [self addSubview:self.profileImageView];
        
        _nameLabel = [[UILabel alloc] init];
        self.nameLabel.numberOfLines = 0;
        self.nameLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:20.0];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:self.nameLabel];
        
        _trophyCountLabel = [[UILabel alloc] init];
        self.trophyCountLabel.numberOfLines = 1;
        self.trophyCountLabel.font = [UIFont fontWithName:@"Avenir-Book" size:14.0];
        self.trophyCountLabel.textAlignment = NSTextAlignmentCenter;
        self.trophyCountLabel.textColor = [UIColor unselectedGrayColor];
        [self addSubview:self.trophyCountLabel];
        
        _rankLabel = [[UILabel alloc] init];
        self.rankLabel.numberOfLines = 1;
        self.rankLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:25.0];
        self.rankLabel.textColor = [UIColor darkGrayColor];
        self.accessoryView = self.rankLabel;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.score) {
        [self layoutCellViews];
    }
}

- (void)layoutCellViews
{
    CGRect frame = self.profileImageView.frame;
    frame.origin.x = kCellSideMargin;
    frame.origin.y = 30.0;
    frame.size = CGSizeMake(kCellProfileImageWidth, kCellProfileImageWidth);
    self.profileImageView.frame = frame;
    
    [self.nameLabel sizeToFit];
    CGFloat maxWidth = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.profileImageView.frame) - CGRectGetWidth(self.accessoryView.frame) - 2 * kCellInnerMargin - 2 * kCellSideMargin;
    frame = self.nameLabel.frame;
    frame.origin.x = CGRectGetMidX(self.bounds) - floorf(maxWidth / 2.0);
    frame.origin.y = 30.0;
    frame.size.width = maxWidth;
    self.nameLabel.frame = frame;

    [self.trophyCountLabel sizeToFit];
    frame = self.trophyCountLabel.frame;
    frame.origin.x = CGRectGetMinX(self.nameLabel.frame);
    frame.origin.y = CGRectGetMaxY(self.nameLabel.frame) + 10.0;
    frame.size.width = maxWidth;
    self.trophyCountLabel.frame = frame;
}

- (void)setScore:(TALeaderboardScore *)score
{
    _score = score;
    self.nameLabel.text = self.score.user.name;
    self.trophyCountLabel.text = [NSString stringWithFormat:@"%ld trophies", self.score.trophyCount];
    PFFile *imageFile = [self.score.user parseFileForProfileImage];
    self.profileImageView.file = imageFile;
    [self.profileImageView loadInBackground];
    
    [self layoutCellViews];
}

- (void)setRank:(NSInteger)rank
{
    self.rankLabel.text = [NSString stringWithFormat:@"%@", [self rankStringForNumber:rank]];
    [self.rankLabel sizeToFit];
    
    [self layoutCellViews];
}

- (CGFloat)heightForCell
{
    return CGRectGetMaxY(self.trophyCountLabel.frame) + kCellSideMargin;
}

- (NSString *)rankStringForNumber:(NSInteger)number {
    NSString *numStr = [NSString stringWithFormat:@"%ld", (long)number];
    NSString *lastDigit = [numStr substringFromIndex:([numStr length] - 1)];
    
    NSString *ordinal;
    if ([numStr isEqualToString:@"11"] || [numStr isEqualToString:@"12"] || [numStr isEqualToString:@"13"]) {
        ordinal = @"th";
    } else if ([lastDigit isEqualToString:@"1"]) {
        ordinal = @"st";
    } else if ([lastDigit isEqualToString:@"2"]) {
        ordinal = @"nd";
    } else if ([lastDigit isEqualToString:@"3"]) {
        ordinal = @"rd";
    } else {
        ordinal = @"th";
    }
    return [NSString stringWithFormat:@"%@%@", numStr, ordinal];
}

@end
