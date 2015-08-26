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
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
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
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [self.flashButton setBackgroundImage:[UIImage imageNamed:@"camera-flash-off"] forState:UIControlStateNormal];
        [self.flashButton setBackgroundImage:[UIImage imageNamed:@"camera-flash-on"] forState:UIControlStateSelected];
        [self.flashButton addTarget:self action:@selector(didSelectFlashButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.flashButton];
        
        _rotateButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.rotateButton setBackgroundImage:[UIImage imageNamed:@"rotate-camera"] forState:UIControlStateNormal];
        [self.rotateButton addTarget:self action:@selector(didSelectRotateButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rotateButton];

        _cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.cancelButton setBackgroundImage:[UIImage imageNamed:@"closeup-close-icon"] forState:UIControlStateNormal];
//        self.cancelButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:18.0];
//        [self.cancelButton setTitleColor:[UIColor trophyYellowColor] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(didSelectCancelButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelButton];
        
        _photoAlbumButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.photoAlbumButton setBackgroundImage:[UIImage imageNamed:@"pull-from-existing"] forState:UIControlStateNormal];
        [self.photoAlbumButton addTarget:self action:@selector(didSelectPhotoAlbumButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.photoAlbumButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat margin = self.bounds.size.width * .07;

    CGRect frame = CGRectMake((CGRectGetMidX(self.bounds)-(self.takePhotoButton.frame.size.width / 2.0)), CGRectGetHeight(self.bounds) - 100, kPhotoButtonWidth, kPhotoButtonWidth);
    self.takePhotoButton.frame = frame;

    [self.rotateButton sizeToFit];
    frame = self.rotateButton.frame;
    frame.size = CGSizeMake(45.0, 45.0);
    frame.origin.x = CGRectGetMaxX(self.bounds) - (frame.size.width) - margin / 2.0;
    frame.origin.y = margin * 1.5 ;
    self.rotateButton.frame = frame;

    [self.cancelButton sizeToFit];
    frame = self.cancelButton.frame;
    frame.size = CGSizeMake(45.0, 45.0);
    frame.origin.x = CGRectGetMinX(self.bounds) + margin;
    frame.origin.y = CGRectGetMaxY(self.bounds) - (margin * 0.8) - frame.size.height;
    self.cancelButton.frame = frame;
    
    [self.photoAlbumButton sizeToFit];
    frame = self.photoAlbumButton.frame;
    frame.size = CGSizeMake(45.0, 40.0);
    frame.origin.x = CGRectGetMaxX(self.bounds) - margin - frame.size.width;
    frame.origin.y = CGRectGetMaxY(self.bounds) - margin - frame.size.height;
    self.photoAlbumButton.frame = frame;
    
    [self.flashButton sizeToFit];
    frame = self.flashButton.frame;
    frame.size = CGSizeMake(45.0, 45.0);
    frame.origin.x = margin;
    frame.origin.y = margin * 1.5 ;
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

- (IBAction)didSelectFlashButton:(UIButton *)flashButton;
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
