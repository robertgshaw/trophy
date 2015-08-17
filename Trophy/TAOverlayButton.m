//
//  TAOverlayButton.m
//  Trophy
//
//  Created by Robert Shaw on 7/30/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAOverlayButton.h"
#import "TACommentTableViewController.h"

@implementation TAOverlayButton

@synthesize titleLabel = _titleLabel;

- (instancetype) initWithDelegate:(id<TACommentTableViewControllerDelegate, TAOverlayButtonDelegate>) delegate
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
        self.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:18.0];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.5;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.titleLabel];
        
        // configures date label
        self.dateLabel = [[UILabel alloc] init];
        [self.dateLabel setTextAlignment:NSTextAlignmentLeft];
        self.dateLabel.textColor = [UIColor trophyYellowColor];
        self.dateLabel.font = [UIFont fontWithName:@"Avenir-Book" size:14.0];
        [self addSubview:self.dateLabel];
        
        // configures recipient label
        self.recipientLabel = [[UILabel alloc] init];
        [self.recipientLabel setTextAlignment:NSTextAlignmentLeft];
        self.recipientLabel.textColor = [UIColor whiteColor];
        self.recipientLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16.0];
        [self addSubview:self.recipientLabel];

        // configures likes button
        self.likesButton = [[TALikesButton alloc] initWithFrame:CGRectZero];
        [self addSubview:self.likesButton];
        
        // configures comment button
        self.commentsButton = [[UIButton alloc] init];
        [self.commentsButton setBackgroundImage:[UIImage imageNamed:@"commentButton"] forState:UIControlStateNormal];
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
    
    // configures recipient label
    [self.recipientLabel sizeToFit];
    CGRect frame = self.recipientLabel.frame;
    frame.origin.x = self.bounds.size.width / 10;
    frame.origin.y = self.bounds.size.height / 10;
    self.recipientLabel.frame = frame;
    
    // configures title label
    [self.titleLabel sizeToFit];
    frame = self.titleLabel.frame;
    frame.origin.x = self.bounds.size.width / 10;
    frame.origin.y = CGRectGetMinY(self.recipientLabel.frame) + (floorf(self.recipientLabel.font.lineHeight) * 1.25);
    self.titleLabel.frame = frame;
    

    // configures date label
    [self.dateLabel sizeToFit];
    frame = self.dateLabel.frame;
    frame.origin.x = CGRectGetMidX(self.bounds) - (self.dateLabel.bounds.size.width / 2);
    frame.origin.y = CGRectGetMaxY(self.bounds) - 35.0 - (self.dateLabel.bounds.size.height / 2);
    self.dateLabel.frame = frame;

    // configures like button
    frame = self.likesButton.frame;
    frame.size = CGSizeMake([TALikesButton likeButtonWidth], 20.0);
    frame.origin.x = CGRectGetMaxX(self.bounds) - 70.0;
    frame.origin.y = CGRectGetMaxY(self.bounds) - 40.0 - (self.likesButton.bounds.size.height / 2);
    self.likesButton.frame = frame;
    
    // configures comment button
    frame = self.commentsButton.frame;
    frame.size = CGSizeMake(25.0, 25.0);
    frame.origin.x = self.bounds.size.width / 10;
    frame.origin.y = CGRectGetMaxY(self.bounds) - 35.0 - (self.commentsButton.bounds.size.height / 2);
    self.commentsButton.frame = frame;

}

// jumps back to delegate on comment button click
- (void) didPressCommentsButton
{
    [self.delegate overlayViewDidPressCommentsButton];
    
}
@end
