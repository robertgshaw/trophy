//
//  TACreateGroupView.h
//  Trophy
//
//  Created by Gigster on 1/24/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TACreateGroupView;

@protocol TACreateGroupViewDelegate <NSObject>

- (void)createGroupViewDidFinishEnteringInformation:(TACreateGroupView *)createGroupView;
- (void)createGroupViewShouldShowNextButton:(TACreateGroupView *)createGroupView enabled:(BOOL)enabled;

@end

@interface TACreateGroupView : UIView

@property (nonatomic, weak) id<TACreateGroupViewDelegate> delegate;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, assign) NSInteger maxGroupSize;

@end
