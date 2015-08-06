//
//  TATrophyCloseupView.h
//  Trophy
//
//  Created by Gigster on 1/12/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TAOverlayButton.h"
#import "TATrophy.h"
#import "TATrophyActionFooterView.h"
#import "TALikesButton.h"


@class TATrophyCloseupView;

@protocol TATrophyCloseupViewDelegate <NSObject>

- (void)closeupViewDidPressCommentsButton:(TATrophyCloseupView *)TrophyCloseupView;
- (void)backButtonPressed;

@end


@interface TATrophyCloseupView : UIView

- (instancetype)initWithDelegate:(id< TALikeButtonDelegate, TATrophyCloseupViewDelegate>)delegate;

@property (nonatomic, weak) id<TATrophyCloseupViewDelegate> delegate1;

@property (nonatomic, strong) TATrophy *trophy;

@end
