//
//  TAProfileHeaderView.h
//  Trophy
//
//  Created by Gigster on 1/11/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TAUser.h"
#import "TALeaderboardScore.h"

@class TAProfileHeaderView;

@protocol TAProfileHeaderViewDelegate <NSObject>

- (void)profileHeaderViewDidPressEdit:(TAProfileHeaderView *)profileHeaderView;

@end

@interface TAProfileHeaderView : UIView

@property (nonatomic, weak) id<TAProfileHeaderViewDelegate> delegate;
@property (nonatomic, strong) TAUser *user;
@property (nonatomic, strong) TALeaderboardScore *leaderboardScore;

- (CGFloat)heightForProfileHeader;

@end
