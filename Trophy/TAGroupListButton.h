//
//  TAGroupListButton.h
//  Trophy
//
//  Created by Robert Shaw on 7/28/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAGroupListButton : UIButton

@property (strong, nonatomic) UIView *groupListView;
@property (strong, nonatomic) UILabel *groupListLabel;
@property (strong, nonatomic) UIImageView *downArrowImageView;

- (void)updateGroupsButtonWithName:(NSString *)name;

@end
