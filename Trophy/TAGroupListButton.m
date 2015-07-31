//
//  TAGroupListButton.m
//  Trophy
//
//  Created by Robert Shaw on 7/28/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAGroupListButton.h"
#import "TAGroupManager.h"
#import "UIColor+TAAdditions.h"

static const CGFloat kGroupsButtonWidth = 80.0;
static const CGFloat kGroupsButtonHeight = 70.0;

@implementation TAGroupListButton

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    // creates the label to display the name of the current group
    self.groupListView = [[UIView alloc] initWithFrame:self.frame];
    self.groupListLabel = [[UILabel alloc] init];
    self.groupListLabel.text = [TAGroupManager sharedManager].activeGroup.name;

    self.groupListLabel.textColor = [UIColor whiteColor];
    self.groupListLabel.textAlignment = NSTextAlignmentCenter;
    self.groupListLabel.font = [UIFont boldSystemFontOfSize:20.0];
    [self.groupListLabel sizeToFit];
    [self.groupListView addSubview:self.groupListLabel];
    
    // adds the down arrow
    self.downArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down-arrow"]];
    [self.groupListView addSubview:self.downArrowImageView];
    
    frame = self.groupListLabel.frame;
    frame.origin.x = floorf((kGroupsButtonWidth - CGRectGetWidth(self.groupListLabel.frame) - CGRectGetWidth(self.downArrowImageView.frame) - 3.0) / 2.0);
    frame.origin.y = floorf((kGroupsButtonHeight - CGRectGetHeight(self.groupListLabel.frame)) / 2.0);
    self.groupListLabel.frame = frame;

    frame = self.downArrowImageView.frame;
    frame.origin.x = CGRectGetMaxX(self.groupListLabel.frame) + 3.0;
    frame.origin.y = floorf((kGroupsButtonHeight - CGRectGetHeight(self.downArrowImageView.frame)) / 2.0);
    self.downArrowImageView.frame = frame;
    
    // creates the view
    [self addSubview:self.groupListView];
    self.groupListView.userInteractionEnabled = NO;
    
    return self;
}

- (void)updateGroupsButtonWithName:(NSString *)name
{
    // updates the label's text
    self.groupListLabel.text = name;
    
    // updates the positioning
    [self.groupListLabel sizeToFit];
    
    CGRect frame = self.groupListLabel.frame;
    frame.origin.x = floorf((kGroupsButtonWidth - CGRectGetWidth(self.groupListLabel.frame) - CGRectGetWidth(self.downArrowImageView.frame) - 3.0) / 2.0);
    frame.origin.y = floorf((kGroupsButtonHeight - CGRectGetHeight(self.groupListLabel.frame)) / 2.0);
    self.groupListLabel.frame = frame;

    frame = self.downArrowImageView.frame;
    frame.origin.x = CGRectGetMaxX(self.groupListLabel.frame) + 3.0;
    frame.origin.y = floorf((kGroupsButtonHeight - CGRectGetHeight(self.downArrowImageView.frame)) / 2.0);
    self.downArrowImageView.frame = frame;

}

@end
