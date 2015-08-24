//
//  TATimelineTableViewCell.h
//  Trophy
//
//  Created by Gigster on 12/29/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

#import "TATrophy.h"
#import "TAUser.h"
#import "TACommentButton.h"
#import "TALikesButton.h"

@class TATimelineTableViewCell;

@protocol TATimelineTableViewCellDelegate <NSObject>

- (void)timelineCellDidPressProfileButton:(TATimelineTableViewCell *)cell forUser:(TAUser *)user;

@end

@interface TATimelineTableViewCell : PFTableViewCell

@property (nonatomic, weak) id<TATimelineTableViewCellDelegate, TALikeButtonDelegate> delegate;
@property (nonatomic, strong) TALikesButton *likesButton;
@property (nonatomic, strong) UIButton *commentsButton;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UIView *verticalBar;

- (CGFloat)heightOfCell;
- (NSString *)formatDate:(NSDate *)date;

@end
