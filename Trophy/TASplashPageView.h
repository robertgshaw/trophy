//
//  TASplashPageView.h
//  Trophy
//
//  Created by Matt Deveney on 9/4/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TASplashPageView;

@protocol TASplashViewDelegate <NSObject>
@required
- (void)splashPageViewDidPressGetStarted:(TASplashPageView *)splashPageView;
@end

@interface TASplashPageView : UIView

@property (nonatomic, weak) id<TASplashViewDelegate> delegate;

@end
