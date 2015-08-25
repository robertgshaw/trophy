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

- (instancetype)initWithDelegate:(id< TALikeButtonDelegate, TABackButtonDelegate, TATrophyCloseupViewDelegate>)delegate;

@property (nonatomic, weak) id<TATrophyCloseupViewDelegate> delegate1;

@property (nonatomic, strong) TATrophy *trophy;

@property (nonatomic, strong) TABackButton *backButton;
@property (nonatomic, strong) TAFlagButton *flagButton;

-(void) hideOverlay;

@end
