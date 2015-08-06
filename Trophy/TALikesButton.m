//
//  TALikesButton.m
//  Trophy
//
//  Created by Robert Shaw on 8/3/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TALikesButton.h"
#import "UIColor+TAAdditions.h"
#import "TATrophyManager.h"

static const CGFloat kActionFooterWidth = 150.0;
static const CGFloat kButtonWidth = 25.0;

@interface TALikesButton ()

@property (nonatomic, strong) UIButton *likesButton;
@property (nonatomic, strong) UILabel *likesLabel;

@end

@implementation TALikesButton

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

- (void) layoutSubviews
{
    [super layoutSubviews];

    CGRect frame = self.likesButton.frame;
    frame.size = CGSizeMake(kButtonWidth, kButtonWidth);
    frame.origin.x = 0;
    frame.origin.y = 0;
    self.likesButton.frame = frame;
    
    [self.likesLabel sizeToFit];
    frame = self.likesLabel.frame;
    frame.origin.x = CGRectGetMidX(self.likesButton.frame) - 3;
    frame.origin.y = CGRectGetMinY(self.likesButton.frame) + (floorf(self.likesLabel.font.lineHeight) * 2.0);
    self.likesLabel.frame = frame;
}

// configures the trophy
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

// button pressed action handler
- (void)didPressLikesButton
{
    NSLog(@"Like button pressed");
    if (self.likesButton.selected) {
        self.likesButton.selected = NO;
    } else {
        self.likesButton.selected = YES;
    }
    
    // updates likes on parse
    TATrophy *updatedTrophy = [[TATrophyManager sharedManager] likeTrophy:self.trophy];
    self.trophy = updatedTrophy;
    
    // sends updated trophy back to delegate
    [self.delegate likesButtonDidPressLikesButton:(updatedTrophy)];
}

+ (CGFloat)likeButtonWidth
{
    return kActionFooterWidth;
}


@end
