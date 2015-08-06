//
//  TAOverlayButton.h
//  Trophy
//
//  Created by Robert Shaw on 7/30/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+TAAdditions.h"
#import "TATrophyCloseupView.h"
#import "TALikesButton.h"

@protocol TAOverlayButtonDelegate <NSObject>
@required
- (void) overlayViewDidPressCommentsButton;
@end

@interface TAOverlayButton : UIButton

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *recipientLabel;
@property (nonatomic, strong) UIButton *commentsButton;
@property (nonatomic, strong) TALikesButton *likesButton;
@property (nonatomic, strong) id<TAOverlayButtonDelegate> delegate;

-(instancetype) initWithDelegate:(id<TALikeButtonDelegate, TAOverlayButtonDelegate>) delegate;

@end
