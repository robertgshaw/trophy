//
//  TATrophyCollectionViewCell.h
//  Trophy
//
//  Created by Gigster on 1/18/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TATrophyActionFooterView.h"
#import "TATrophy.h"

@interface TATrophyCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) TATrophy *trophy;
@property (nonatomic, weak) id<TATrophyActionFooterDelegate> actionFooterDelegate;

@end
