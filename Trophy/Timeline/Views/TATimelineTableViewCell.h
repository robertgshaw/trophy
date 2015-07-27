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

@class TATimelineTableViewCell;

@protocol TATimelineTableViewCellDelegate <NSObject>

- (void)timelineCellDidPressProfileButton:(TATimelineTableViewCell *)cell forUser:(TAUser *)user;

@end

@interface TATimelineTableViewCell : PFTableViewCell

@property (nonatomic, weak) id<TATimelineTableViewCellDelegate> delegate;
@property (nonatomic, strong) TATrophy *trophy;

- (CGFloat)heightOfCell;

@end
