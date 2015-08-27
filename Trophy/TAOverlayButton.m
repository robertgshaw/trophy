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
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont fontWithName:@"Avenir-Black" size:16.0];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.5;
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.titleLabel];
        
        // configures recipient label
        self.recipientLabel = [[UILabel alloc] init];
        [self.recipientLabel setTextAlignment:NSTextAlignmentLeft];
        self.recipientLabel.textColor = [UIColor whiteColor];
        self.recipientLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
        self.recipientLabel.minimumScaleFactor = 0.5;
        [self addSubview:self.recipientLabel];

        // adds the shadow to the overlay
        [self setBackgroundColor:[UIColor trophyNavyTranslucentColor]];
    
    }
    
    return self;
}

// configures locations of subviews
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // configures title label
    [self.titleLabel sizeToFit];
    CGRect frame = self.titleLabel.frame;
    frame.size.width = self.bounds.size.width * .75;
    frame.origin.x = self.bounds.size.width / 10;
    frame.origin.y = CGRectGetMaxY(self.bounds) - frame.size.height - self.bounds.size.height * .1;
    self.titleLabel.frame = frame;
    
    // configures recipient label
    [self.recipientLabel sizeToFit];
    frame = self.recipientLabel.frame;
    frame.size.width = self.bounds.size.width * .8;
    frame.origin.x = self.bounds.size.width / 10;
    frame.origin.y = CGRectGetMinY(self.titleLabel.frame) - frame.size.height - self.bounds.size.height * .04;
    self.recipientLabel.frame = frame;
    
    if (frame.origin.y < 0) {
        CGRect newOverlayFrame = self.frame;
        newOverlayFrame.size.height = newOverlayFrame.size.height - frame.origin.y  + 7;
        newOverlayFrame.origin.y = newOverlayFrame.origin.y + frame.origin.y - 7;
        self.frame = newOverlayFrame;
    }
    
}
@end
