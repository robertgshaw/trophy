//
//  TASettingsView.h
//  Trophy
//
//  Created by Gigster on 1/1/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TAUser.h"

@class TASettingsView;

@protocol TASettingsViewDelegate <NSObject>
@required
- (void)settingsViewDidPressProfileImageButton:(TASettingsView *)settingsView;
- (void)settingsViewDidPressSaveButton:(TASettingsView *)settingsView;
@end


@interface TASettingsView : UIView

@property (nonatomic, weak) id<TASettingsViewDelegate> delegate;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) UIImage *profileImage;

+ (CGFloat)profileImageWidth;
- (instancetype)initWithSettings:(TAUser *)user;

@end
