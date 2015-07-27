//
//  TATrophyPickerOverlayView.h
//  Trophy
//
//  Created by Gigster on 1/7/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TATrophyPickerOverlayDelegate <NSObject>
@required
- (void)trophyPickerOverlayDidSelectTakePhotoButton;
- (void)trophyPickerOverlayDidSelectRotateButton;
- (void)trophyPickerOverlayDidSelectFlashButton;
- (void)trophyPickerOverlayDidSelectCancelButton;
- (void)trophyPickerOverlayDidSelectPhotoAlbumButton;
@end

@interface TATrophyPickerOverlayView : UIView

@property (nonatomic, weak) id<TATrophyPickerOverlayDelegate> delegate;

@end
