//
//  TACommentButton.h
//  Trophy
//
//  Created by Jason Herrmann on 8/4/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TATrophy.h"

@interface TACommentButton : UIButton

@property int numOfComments;
@property (strong, nonatomic) UILabel *commentsLabel;
@property (strong, nonatomic) UIButton *commentsButton;

- (void)updateNumOfComments;
@end
