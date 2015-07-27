//
//  TALoginView.h
//  Trophy
//
//  Created by Gigster on 1/2/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TALoginView;

@protocol TALoginViewDelegate <NSObject>
@required
- (void)loginViewDidPressContinue:(TALoginView *)loginView;
@end

@interface TALoginView : UIView

@property (nonatomic, weak) id<TALoginViewDelegate> delegate;

@property (nonatomic, assign) BOOL usernameSelected;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *password;

- (BOOL)validateLogin;
- (void)startAnimating;
- (void)stopAnimating;

@end
