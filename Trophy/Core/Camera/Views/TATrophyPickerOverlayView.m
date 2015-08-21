//
//  TATrophyPickerOverlayView.m
//  Trophy
//
//  Created by Gigster on 1/7/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TATrophyPickerOverlayView.h"

#import "UIColor+TAAdditions.h"

static const CGFloat kPhotoButtonWidth = 80.0;

@interface TATrophyPickerOverlayView ()

@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *rotateButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *photoAlbumButton;
@property(nonatomic) UIImagePickerControllerCameraFlashMode cameraFlashMode;

@end

@implementation TATrophyPickerOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _takePhotoButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.takePhotoButton setBackgroundColor:[UIColor mediumTranslucentWhite]];
        self.takePhotoButton.layer.borderColor = [UIColor trophyYellowColor].CGColor;
        self.takePhotoButton.layer.borderWidth = 3.0;
        self.takePhotoButton.layer.cornerRadius = floorf(kPhotoButtonWidth / 2.0);
        self.takePhotoButton.clipsToBounds = YES;
        [self.takePhotoButton addTarget:self action:@selector(didSelectTakePhotoButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.takePhotoButton];
        
        _flashButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.flashButton setBackgroundImage:[UIImage imageNamed:@"flash-on-new"] forState:UIControlStateNormal];
        [self.flashButton setBackgroundImage:[UIImage imageNamed:@"camera-flash-off"] forState:UIControlStateSelected];
        [self.flashButton addTarget:self action:@selector(didSelectFlashButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.flashButton];
        
        _rotateButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.rotateButton setBackgroundImage:[UIImage imageNamed:@"camera-rotate-button"] forState:UIControlStateNormal];
        [self.rotateButton addTarget:self action:@selector(didSelectRotateButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rotateButton];

        _cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        self.cancelButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:18.0];
        [self.cancelButton setTitleColor:[UIColor trophyYellowColor] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(didSelectCancelButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelButton];
        
        _photoAlbumButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.photoAlbumButton setBackgroundImage:[UIImage imageNamed:@"cameraroll"] forState:UIControlStateNormal];
        [self.photoAlbumButton addTarget:self action:@selector(didSelectPhotoAlbumButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.photoAlbumButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect frame = CGRectMake(150, CGRectGetHeight(self.bounds) - 150, kPhotoButtonWidth, kPhotoButtonWidth);
    self.takePhotoButton.frame = frame;

    [self.rotateButton sizeToFit];
    frame = self.rotateButton.frame;
    frame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.rotateButton.frame) - 30.0;
    frame.origin.y = 50.0;
    self.rotateButton.frame = frame;

    [self.cancelButton sizeToFit];
    frame = self.cancelButton.frame;
    frame.origin.x = floorf((CGRectGetMinX(self.takePhotoButton.frame) - CGRectGetWidth(self.cancelButton.frame)) / 2.0);
    frame.origin.y = CGRectGetMidY(self.takePhotoButton.frame) - floorf(CGRectGetHeight(self.cancelButton.frame) / 2.0);
    self.cancelButton.frame = frame;
    
    [self.photoAlbumButton sizeToFit];
    frame = self.photoAlbumButton.frame;
    frame.origin.x = floorf(CGRectGetMaxX(self.takePhotoButton.frame) +
                            (CGRectGetWidth(self.bounds) - CGRectGetMaxX(self.takePhotoButton.frame)
                             - CGRectGetWidth(self.photoAlbumButton.frame)) / 2.0);
    frame.origin.y = CGRectGetMidY(self.takePhotoButton.frame) - floorf(CGRectGetHeight(self.photoAlbumButton.frame) / 2.0);
    self.photoAlbumButton.frame = frame;
    
    [self.flashButton sizeToFit];
    frame = self.flashButton.frame;
    frame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.flashButton.frame) - 250.0;
    frame.origin.y = 50.0;
    self.flashButton.frame = frame;
}

- (void)didSelectTakePhotoButton
{
    [self.delegate trophyPickerOverlayDidSelectTakePhotoButton];
}

- (void)didSelectRotateButton
{
    [self.delegate trophyPickerOverlayDidSelectRotateButton];
}

- (void)didSelectFlashButton
{
    [self.delegate trophyPickerOverlayDidSelectFlashButton];
}

- (void)didSelectCancelButton
{
    [self.delegate trophyPickerOverlayDidSelectCancelButton];
}

- (void)didSelectPhotoAlbumButton
{
    [self.delegate trophyPickerOverlayDidSelectPhotoAlbumButton];
}

@end
