//
//  TATrophyActionFooterView.h
//  Trophy
//
//  Created by Gigster on 12/30/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TATrophy.h"

@protocol TATrophyActionFooterDelegate <NSObject>
@required
- (void)trophyActionFooterDidPressLikesButton;
- (void)trophyActionFooterDidPressCommentsButton;
- (void)trophyActionFooterDidPressAddButton;
@end

@interface TATrophyActionFooterView : UIView

@property (nonatomic, weak) id<TATrophyActionFooterDelegate> delegate;
@property (nonatomic, strong) TATrophy *trophy;
+ (CGFloat)actionFooterWidth;

@end
