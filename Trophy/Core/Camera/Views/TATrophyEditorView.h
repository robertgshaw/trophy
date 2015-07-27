//
//  TATrophyEditorView.h
//  Trophy
//
//  Created by Gigster on 1/7/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TATrophyEditorDelegate <NSObject>

- (void)trophyEditorDidSelectCancel;
- (void)trophyEditorDidSelectSend;

@end

@interface TATrophyEditorView : UIView

@property (nonatomic, weak) id<TATrophyEditorDelegate> delegate;
@property (nonatomic, strong) UIImage *cameraImage;
@property (nonatomic, strong) NSString *caption;

@end
