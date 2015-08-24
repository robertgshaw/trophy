//
//  TATrophyActionFooterView.m
//  Trophy
//
//  Created by Gigster on 12/30/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import "TATrophyActionFooterView.h"
#import "UIColor+TAAdditions.h"
#import "TACommentTableViewController.h"
#import "TATrophyManager.h"

static const CGFloat kButtonWidth = 25.0;
static const CGFloat kSideMargin = -30.0;
static const CGFloat kActionFooterWidth = 150.0;

@interface TATrophyActionFooterView ()

@property (nonatomic, strong) UIButton *likesButton;
@property (nonatomic, strong) UILabel *likesLabel;
@property (nonatomic, strong) UIButton *commentsButton;
@property (nonatomic, strong) UIButton *addButton;

@end

@implementation TATrophyActionFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _likesButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.likesButton setBackgroundImage:[UIImage imageNamed:@"likes-button"] forState:UIControlStateNormal];
        [self.likesButton setBackgroundImage:[UIImage imageNamed:@"likes-button-selected"] forState:UIControlStateSelected];
        [self.likesButton addTarget:self action:@selector(didPressLikesButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.likesButton];
        
        _likesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.likesLabel.text = @"0";
        self.likesLabel.textColor = [UIColor trophyYellowColor];
        self.likesLabel.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.likesLabel];
    
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect frame = self.bounds;
    frame.size = CGSizeMake(kActionFooterWidth, CGRectGetHeight(self.bounds));
    self.bounds = frame;
    
    frame = self.likesButton.frame;
    frame.size = CGSizeMake(kButtonWidth, kButtonWidth);
    frame.origin.x = 2;
    frame.origin.y = 0;
    self.likesButton.frame = frame;
    
    [self.likesLabel sizeToFit];
    frame = self.likesLabel.frame;
    frame.origin.x = 11;
    frame.origin.y = CGRectGetMinY(self.likesButton.frame) + (floorf(self.likesLabel.font.lineHeight) * 2.0);
    self.likesLabel.frame = frame;
}

- (void)setTrophy:(TATrophy *)trophy
{
    _trophy = trophy;
    self.likesLabel.text = [NSString stringWithFormat:@"%ld", (long)trophy.likes];
    if ([trophy likedByCurrentUser]) {
        self.likesButton.selected = YES;
    } else {
        self.likesButton.selected = NO;
    }
}

- (void)didPressLikesButton
{
    if (self.likesButton.selected) {
        self.likesButton.selected = NO;
    } else {
        self.likesButton.selected = YES;
    }
    TATrophy *updatedTrophy = [[TATrophyManager sharedManager] likeTrophy:self.trophy];
    self.trophy = updatedTrophy;
}


+ (CGFloat)actionFooterWidth
{
    return kActionFooterWidth;
}

@end
