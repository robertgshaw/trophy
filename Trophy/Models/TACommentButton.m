//
//  TACommentButton.m
//  Trophy
//
//  Created by Jason Herrmann on 8/4/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TACommentButton.h"

@implementation TACommentButton
@synthesize trophy;

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        [self setBackgroundImage:[UIImage imageNamed:@"commentButton"] forState:UIControlStateNormal];
        CGRect frame = CGRectMake(0, 0, 25.0, 25.0);
        frame.size = CGSizeMake(25.0, 25.0);
        
        [self setFrame:frame];
        
        self.titleLabel.text = @"";
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.titleLabel sizeToFit];
    }
    
    
    return self;
}

- (void)updateNumOfComments {
    
    self.titleLabel.text = [[NSString alloc] initWithFormat:@"%d", self.numOfComments];
    [self.titleLabel sizeToFit];
}

@end
