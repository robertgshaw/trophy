//
//  TACommentButton.m
//  Trophy
//
//  Created by Jason Herrmann on 8/4/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TACommentButton.h"
#import "UIColor+TAAdditions.h"

@implementation TACommentButton

- (id)init {
    
    self = [super init];
    if (self) {
        
        self.titleLabel.text = @"";
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.titleLabel sizeToFit];
        
        // creates the button for the comment logo
        self.commentsButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.commentsButton setBackgroundImage:[UIImage imageNamed:@"commentButton"] forState:UIControlStateNormal];
        
        // creates the label for the comment count
        _commentsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.commentsLabel.textColor = [UIColor trophyYellowColor];
        self.commentsLabel.font = [UIFont boldSystemFontOfSize:10.0];
        self.commentsLabel.numberOfLines = 1;
        [self addSubview:self.commentsLabel];
    }
    
    
    return self;
}

- (void) layoutSubviews
{
    self.commentsButton.frame = CGRectMake(0, 0, 20, 20);
    
    [self.commentsLabel sizeToFit];
    CGRect frame = self.commentsLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.commentsButton.frame) + 3;
    frame.origin.y = self.commentsButton.frame.origin.y;
    self.commentsLabel.frame = frame;
}

- (void)updateNumOfComments {
    
    self.titleLabel.text = [[NSString alloc] initWithFormat:@"%d", self.numOfComments];
    [self.titleLabel sizeToFit];
}

@end
