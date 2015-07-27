//
//  TAJoinGroupView.h
//  Trophy
//
//  Created by Gigster on 1/30/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TAJoinGroupView;

@protocol TAJoinGroupViewDelegate <NSObject>

- (void)joinGroupViewShouldShowJoinButton:(TAJoinGroupView *)joinGroupView enabled:(BOOL)enabled;
- (void)joinGroupViewDidFinishEnteringInformation:(TAJoinGroupView *)joinGroupView;

@end

@interface TAJoinGroupView : UIView

@property (nonatomic, weak) id<TAJoinGroupViewDelegate> delegate;

@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *inviteCode;

@end
