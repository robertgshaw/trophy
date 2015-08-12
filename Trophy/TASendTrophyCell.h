//
//  TASendTrophyCell.h
//  Trophy
//
//  Created by Robert Shaw on 8/10/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "TAUser.h"

@interface TASendTrophyCell : PFTableViewCell

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) PFImageView *profileImageView;

+ (CGFloat)heightOfCell;

@end
