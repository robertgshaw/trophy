//
//  TASignupView.h
//  Trophy
//
//  Created by Gigster on 12/10/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "TAUser.h"

@class TASignupView;

@protocol TASignupViewDelegate <NSObject>
@required
- (void)signupViewDidPressContinueButton;
- (void)signupViewDidPressLoginButton;
@end

@interface TASignupView : UIView

@property (nonatomic, weak) id<TASignupViewDelegate> delegate;
@property (nonatomic, strong) TAUser *user;

- (BOOL)signupIsValid;
- (NSString *)signupError;
- (void)startAnimating;
- (void)stopAnimating;

@end
