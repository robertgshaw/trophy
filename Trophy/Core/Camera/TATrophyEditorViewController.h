//
//  TATrophyEditorViewController.h
//  Trophy
//
//  Created by Gigster on 1/7/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TATrophyEditorViewControllerDelegate <NSObject>

- (void)trophyEditorViewControllerDidSendTrophyWithSuccess;

@end

@interface TATrophyEditorViewController : UIViewController

@property (nonatomic, weak) id<TATrophyEditorViewControllerDelegate> delegate;

- (instancetype)initWithImage:(UIImage *)image;

@end
