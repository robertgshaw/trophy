//
//  TAFlagButton.h
//  Trophy
//
//  Created by Robert Shaw on 8/11/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TATrophy.h"

@protocol TAFlagButtonDelegate <NSObject>

-(TATrophy *)getTATrophy;

@end

@interface TAFlagButton : UIButton

@property (nonatomic, weak) id<TAFlagButtonDelegate> delegate;

@end
