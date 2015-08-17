//
//  TAAddSettingsView.m
//  Trophy
//
//  Created by Gigster on 12/21/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import "TAAddSettingsView.h"

#import "UIColor+TAAdditions.h"
#import "UITextField+TAAdditions.h"

static const CGFloat kTextFieldWidth = 200.0;
static const CGFloat kTextFieldHeight = 40.0;
static const CGFloat kContinueButtonWidth = 180.0;
static const CGFloat kContinueButtonHeight = 40.0;

@interface TAAddSettingsView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *nameInput;
@property (nonatomic, strong) UITextField *descriptionInput;
@property (nonatomic, strong) UIButton *profileImageButton;
@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation TAAddSettingsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor trophyNavyColor];

        _nameInput = [TATextField textFieldWithYellowBorder];
        self.nameInput.delegate = self;
        self.nameInput.placeholder = @"Name";
        self.nameInput.borderStyle = UITextBorderStyleRoundedRect;
        self.nameInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.nameInput.font = [UIFont fontWithName:@"Avenir-Book" size:12.0];
        self.nameInput.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.nameInput.returnKeyType = UIReturnKeyNext;
        [self addSubview:self.nameInput];

        _descriptionInput = [TATextField textFieldWithYellowBorder];
        self.descriptionInput.delegate = self;
        self.descriptionInput.placeholder = @"College";
        self.descriptionInput.font = [UIFont fontWithName:@"Avenir-Book" size:12.0];
        self.descriptionInput.borderStyle = UITextBorderStyleRoundedRect;
        self.descriptionInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.descriptionInput.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        self.descriptionInput.returnKeyType = UIReturnKeyDone;
        [self addSubview:self.descriptionInput];

        _profileImageButton = [[UIButton alloc] init];
        [self.profileImageButton setBackgroundImage:[UIImage imageNamed:@"default-create-profile-icon"] forState:UIControlStateNormal];
        [self.profileImageButton setTitleColor:[UIColor trophyYellowColor] forState:UIControlStateNormal];
        [self.profileImageButton addTarget:self action:@selector(profileImageButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.profileImageButton.layer.borderWidth = 3.0f;
        self.profileImageButton.layer.borderColor = [UIColor trophyYellowColor].CGColor;
        self.profileImageButton.clipsToBounds = YES;
        [self addSubview:self.profileImageButton];

        _saveButton = [[UIButton alloc] init];
        [self.saveButton setTitle:@"Save and Continue" forState:UIControlStateNormal];
        [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.saveButton.backgroundColor = [UIColor standardBlueButtonColor];
        [self.saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.saveButton.hidden = YES;
        self.saveButton.layer.cornerRadius = 5.0;
        self.saveButton.layer.borderWidth = 1.0;
        self.saveButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:self.saveButton];
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat margin = 30.0;

    CGRect frame = self.nameInput.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - kTextFieldWidth) / 2.0);
    frame.origin.y = 50.0;
    frame.size.width = kTextFieldWidth;
    frame.size.height = kTextFieldHeight;
    self.nameInput.frame = frame;

    frame = self.descriptionInput.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - kTextFieldWidth) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.nameInput.frame) + margin;
    frame.size.width = kTextFieldWidth;
    frame.size.height = kTextFieldHeight;
    self.descriptionInput.frame = frame;

    frame = self.profileImageButton.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - kTextFieldWidth) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.descriptionInput.frame) + margin + 20;
    frame.size.width = kTextFieldWidth;
    frame.size.height = kTextFieldWidth;
    self.profileImageButton.frame = frame;
    self.profileImageButton.layer.cornerRadius = floorf(CGRectGetWidth(self.profileImageButton.frame) / 2.0);

    [self.saveButton sizeToFit];
    frame = self.saveButton.frame;
    frame.size.width = kContinueButtonWidth;
    frame.size.height = kContinueButtonHeight;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - kContinueButtonWidth)/ 2.0);
    frame.origin.y = CGRectGetMaxY(self.profileImageButton.frame) + margin * 0.5;
    self.saveButton.frame = frame;
}

#pragma mark - Private Methods

- (void)profileImageButtonPressed
{
    [self.delegate settingsViewDidPressProfileImageButton:self];
}

- (void)saveButtonPressed
{
    [self.delegate settingsViewDidPressSaveButton:self];
}

- (void)shouldShowSaveButton
{
    if ([self.nameInput.text length] > 0 && [self.descriptionInput.text length] > 0) {
        self.saveButton.hidden = NO;
    } else {
        self.saveButton.hidden = YES;
    }
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self shouldShowSaveButton];
    return YES;
}

@end
