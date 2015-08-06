//
//  TALikesButton.h
//  Trophy
//
//  Created by Robert Shaw on 8/3/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TATrophy.h"

@protocol TALikeButtonDelegate <NSObject>
@required
- (void)didPressLikesButton;
@end

@interface TALikesButton : UIButton

@property (nonatomic, weak) id<TALikeButtonDelegate> delegate;
@property (nonatomic, strong) TATrophy *trophy;
+ (CGFloat)likeButtonWidth;

@end
