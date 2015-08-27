//
//  TATrophyCloseupView.h
//  Trophy
//
//  Created by Gigster on 1/12/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TATrophy.h"
#import "TATrophyActionFooterView.h"
#import "TALikesButton.h"
#import "TABackButton.h"
#import "TAFlagButton.h"
#import "TAOverlayButton.h"


@class TATrophyCloseupView;

@protocol TATrophyCloseupViewDelegate <NSObject>

- (void)closeupViewDidPressCommentsButton:(TATrophyCloseupView *)TrophyCloseupView;
- (void)hideDisplays;


@end


@interface TATrophyCloseupView : UIView

- (instancetype)initWithDelegate:(id< UIScrollViewDelegate, TALikeButtonDelegate, TABackButtonDelegate, TATrophyCloseupViewDelegate>)delegate;

@property (nonatomic, weak) id< UIScrollViewDelegate, TATrophyCloseupViewDelegate, TALikeButtonDelegate, TABackButtonDelegate> delegate1;

@property (nonatomic, strong) TATrophy *trophy;
@property (nonatomic, strong) UIButton *commentsButton;
@property (nonatomic, strong) TALikesButton *likesButton;
@property (nonatomic, strong) TABackButton *backButton;
@property (nonatomic, strong) TAFlagButton *flagButton;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *deleteButton;
@property BOOL isAbleToBeDeleted;

-(void) hideOverlay;

@end
