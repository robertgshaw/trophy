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

@class TATrophyCloseupView;

@protocol TATrophyCloseupViewDelegate <NSObject>

- (void)closeupViewDidPressCommentsButton:(TATrophyCloseupView *)TrophyCloseupView;

@end


@interface TATrophyCloseupView : UIView

- (instancetype)initWithDelegate:(id<TATrophyActionFooterDelegate>)delegate;

@property (nonatomic, weak) id<TATrophyCloseupViewDelegate> delegate1;

@property (nonatomic, strong) TATrophy *trophy;

@end
