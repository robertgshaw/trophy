//
//  TABackButton.h
//  Trophy
//
//  Created by Robert Shaw on 8/11/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TABackButtonDelegate <NSObject>
@required
- (void)backButtonDidPressBack;
@end

@interface TABackButton : UIButton

@property (nonatomic, weak) id<TABackButtonDelegate> delegate;

@end
