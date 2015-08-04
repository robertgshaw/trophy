//
//  TAOverlayButton.m
//  Trophy
//
//  Created by Robert Shaw on 7/30/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAOverlayButton.h"


@implementation TAOverlayButton

@synthesize titleLabel = _titleLabel;

- (instancetype) initWithDelegate:(id<TATrophyActionFooterDelegate, TAOverlayButtonDelegate>) delegate
{
    self = [super init];
    if (self) {
    
        self.delegate = delegate;
        
        self.backgroundColor = [UIColor clearColor];
        //[self setBackgroundImage:[UIImage imageNamed:@"likes-button"] forState:UIControlStateSelected];
        //[self addTarget:self action:@selector(didPressOverlay) forControlEvents:UIControlEventTouchUpInside];
        
        //
        // configures title label
        self.titleLabel = [[UILabel alloc] init];
        [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
        self.titleLabel.textColor = [UIColor trophyYellowColor];
        self.titleLabel.font = [UIFont systemFontOfSize:16.0];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.5;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
       // [self addSubview:self.titleLabel];
        
        // configures date label
        self.dateLabel = [[UILabel alloc] init];
        [self.dateLabel setTextAlignment:NSTextAlignmentLeft];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.dateLabel.font = [UIFont systemFontOfSize:16.0];
        //[self addSubview:self.dateLabel];
        
        // configures recipient label
        self.recipientLabel = [[UILabel alloc] init];
        [self.recipientLabel setTextAlignment:NSTextAlignmentLeft];
        self.recipientLabel.textColor = [UIColor whiteColor];
        self.recipientLabel.font = [UIFont boldSystemFontOfSize:20];
        [self addSubview:self.recipientLabel];
        
        // configures action footer view
        self.actionFooterView = [[TATrophyActionFooterView alloc] initWithFrame:CGRectZero];
        self.actionFooterView.delegate = delegate;
        [self addSubview:self.actionFooterView];
        
        // configures comment button
        self.commentsButton = [[UIButton alloc] init];
        [self.commentsButton setBackgroundImage:[UIImage imageNamed:@"commentButton"] forState:UIControlStateNormal];
        [self.commentsButton addTarget:self action:@selector(didPressCommentsButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.commentsButton];
        
    }
    
    return self;
}

// configures locations of subviews
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // configures title label
    [self.titleLabel sizeToFit];
    CGFloat width = 100;
    CGRect frame = self.titleLabel.frame;
    frame.origin.x = 20.0;
    frame.origin.y = 20.0;
    frame.size.width = width;
    self.titleLabel.frame = frame;
    
    // configures recipient label
    [self.recipientLabel sizeToFit];
    frame = self.recipientLabel.frame;
    frame.origin.x = self.bounds.size.width / 10;
    frame.origin.y = self.bounds.size.height / 10;
    self.recipientLabel.frame = frame;
    
    // configures date label
    [self.dateLabel sizeToFit];
    frame = self.dateLabel.frame;
    frame.origin.x = self.recipientLabel.frame.origin.x;
    frame.origin.y = self.recipientLabel.frame.origin.y + self.recipientLabel.frame.size.height + 2;
    self.dateLabel.frame = frame;

    // configures likes button
    frame = self.actionFooterView.frame;
    frame.size = CGSizeMake([TATrophyActionFooterView actionFooterWidth], 20.0);
    frame.origin.x = CGRectGetMaxX(self.bounds) - 70.0;
    frame.origin.y = CGRectGetMaxY(self.bounds) - 50.0;
    self.actionFooterView.frame = frame;
    
    // configures comment button
    frame.size = CGSizeMake(25.0, 25.0);
    frame.origin.x = self.bounds.size.width / 10;
    frame.origin.y = CGRectGetMaxY(self.bounds) - 50.0;
    self.commentsButton.frame = frame;

}

// jumps back to delegate on comment button click
- (void) didPressCommentsButton
{
    [self.delegate overlayViewDidPressCommentsButton];
    
}
@end
