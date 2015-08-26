//
//  TAOverlayButton.m
//  Trophy
//
//  Created by Robert Shaw on 7/30/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAOverlayButton.h"
#import "TACommentTableViewController.h"

static const CGFloat closeupMargin = 3;

@implementation TAOverlayButton

@synthesize titleLabel = _titleLabel;

- (instancetype) initWithDelegate:(id<TACommentTableViewControllerDelegate, TALikeButtonDelegate, TAOverlayButtonDelegate>) delegate
{
    self = [super init];
    if (self) {
    
        // sets delegate
        self.delegate = delegate;
        
        self.backgroundColor = [UIColor clearColor];
    
        // configures title label
        self.titleLabel = [[UILabel alloc] init];
        [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
        self.titleLabel.textColor = [UIColor trophyYellowColor];
        self.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:16.0];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.5;
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.titleLabel];
        
        // configures date label
        self.dateLabel = [[UILabel alloc] init];
        [self.dateLabel setTextAlignment:NSTextAlignmentLeft];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.dateLabel.font = [UIFont fontWithName:@"Avenir-Book" size:14.0];
        [self addSubview:self.dateLabel];
        
        // configures recipient label
        self.recipientLabel = [[UILabel alloc] init];
        [self.recipientLabel setTextAlignment:NSTextAlignmentLeft];
        self.recipientLabel.textColor = [UIColor whiteColor];
        self.recipientLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
        self.recipientLabel.minimumScaleFactor = 0.5;
        [self addSubview:self.recipientLabel];

        // configures likes button
        self.likesButton = [[TALikesButton alloc] initWithFrame:CGRectZero];
        self.likesButton.delegate = delegate;
        [self addSubview:self.likesButton];
        
        // configures comment button
        self.commentsButton = [[UIButton alloc] init];
        [self.commentsButton setBackgroundImage:[UIImage imageNamed:@"comment-icon"] forState:UIControlStateNormal];
        [self.commentsButton addTarget:self action:@selector(didPressCommentsButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.commentsButton];
        
        // adds the shadow to the overlay
        [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    
    }
    
    return self;
}

// configures locations of subviews
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat margin = self.bounds.size.width * .07;
    
    // configures recipient label
    [self.recipientLabel sizeToFit];
    CGRect frame = self.recipientLabel.frame;
    frame.size.width = self.bounds.size.width * .8;
    frame.origin.x = self.bounds.size.width / 10;
    frame.origin.y = self.bounds.size.height / 10;
    self.recipientLabel.frame = frame;
        
    // configures title label
    [self.titleLabel sizeToFit];
    frame = self.titleLabel.frame;
    frame.size.width = self.bounds.size.width * .8;
    frame.origin.x = self.bounds.size.width / 10;
    frame.origin.y = CGRectGetMinY(self.recipientLabel.frame) + (floorf(self.recipientLabel.font.lineHeight) * 1.1);
    self.titleLabel.frame = frame;
    
    // configures date label
    [self.dateLabel sizeToFit];
    frame = self.dateLabel.frame;
    frame.size.height = self.frame.size.height * .08;
    frame.origin.x = CGRectGetMidX(self.bounds) - (self.dateLabel.bounds.size.width / 2);
    frame.origin.y = CGRectGetMaxY(self.bounds) - frame.size.height - margin;
    self.dateLabel.frame = frame;

    // configures like button
    frame = self.likesButton.frame;
    frame.size = CGSizeMake([TALikesButton likeButtonWidth], 40.0);
    frame.origin.x = CGRectGetMaxX(self.bounds) - margin - frame.size.width;
    frame.origin.y = CGRectGetMaxY(self.bounds) - (closeupMargin * 2) - frame.size.height;
    self.likesButton.frame = frame;
    
    // configures comment button
    frame = self.commentsButton.frame;
    frame.size = CGSizeMake(25.0, 25.0);
    frame.origin.x = CGRectGetMinX(self.likesButton.frame) - frame.size.width - 10;
    frame.origin.y = self.likesButton.frame.origin.y + closeupMargin;
    self.commentsButton.frame = frame;

}

// jumps back to delegate on comment button click
- (void) didPressCommentsButton
{
    [self.delegate overlayViewDidPressCommentsButton];
    
}
@end
