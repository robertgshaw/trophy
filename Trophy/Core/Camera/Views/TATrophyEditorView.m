//
//  TATrophyEditorView.m
//  Trophy
//
//  Created by Gigster on 1/7/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TATrophyEditorView.h"

#import "UIColor+TAAdditions.h"

static const CGFloat kTrophySendIconWidth = 70.0;

@interface TATrophyEditorView () <UIGestureRecognizerDelegate,
                                  UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UITextField *captionTextField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UILabel *descriptionLabel;

@end

@implementation TATrophyEditorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.backgroundImageView setUserInteractionEnabled:YES];
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.backgroundImageView];
        
        _backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        self.backgroundView.backgroundColor = [UIColor trophyNavyLessTranslucentColor];
        self.backgroundView.hidden = YES;
        [self addSubview:self.backgroundView];
        
        _captionTextField = [[UITextField alloc] init];
        self.captionTextField.delegate = self;
        self.captionTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.captionTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        self.captionTextField.returnKeyType = UIReturnKeyDone;
        self.captionTextField.backgroundColor = [UIColor clearColor];
        self.captionTextField.tintColor = [UIColor whiteColor];
        self.captionTextField.textColor = [UIColor whiteColor];
        self.captionTextField.textAlignment = NSTextAlignmentCenter;
        self.captionTextField.font = [UIFont fontWithName:@"Avenir" size:24.0];
        self.captionTextField.hidden = YES;
        [self addSubview:self.captionTextField];
        
        _closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.closeButton setBackgroundImage:[UIImage imageNamed:@"closeup-close-icon"] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(didPressClose) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];

        _sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.sendButton setBackgroundImage:[UIImage imageNamed:@"trophy-send-icon"] forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(didPressSend) forControlEvents:UIControlEventTouchUpInside];
        self.sendButton.enabled = NO;
        self.sendButton.hidden = YES;
        [self addSubview:self.sendButton];

        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        gestureRecognizer.cancelsTouchesInView = NO;
        gestureRecognizer.delegate = self;
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.backgroundImageView.frame = self.bounds;
    
    //lay out close button
    [self.closeButton sizeToFit];
    CGRect frame = self.closeButton.frame;
    frame.size = CGSizeMake(45.0, 45.0);
    frame.origin.x = 30.0;
    frame.origin.y = 30.0;
    self.closeButton.frame = frame;
    
    //lays out translucent background view
    frame.origin.x = 0.0;
    frame.origin.y = 0.0;
    frame.size.width = CGRectGetWidth(self.bounds);
    frame.size.height = CGRectGetHeight(self.bounds);
    self.backgroundView.frame = frame;
    
    //lay out text field
    frame.size.width = CGRectGetWidth(self.bounds);
    frame.size.height = 25;
    frame.origin.x = CGRectGetMidX(self.bounds) - (frame.size.width / 2);
    frame.origin.y = CGRectGetMidY(self.bounds) - (frame.size.height / 2);
    self.captionTextField.frame = frame;

    //lay out send button
    [self.sendButton sizeToFit];
    frame = self.sendButton.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - kTrophySendIconWidth) / 2.0);
    frame.origin.y = CGRectGetHeight(self.bounds) - 150.0;
    frame.size = CGSizeMake(kTrophySendIconWidth, kTrophySendIconWidth);
    self.sendButton.frame = frame;
}

- (void)setCameraImage:(UIImage *)cameraImage
{
    _cameraImage = cameraImage;

    [self.backgroundImageView setImage:cameraImage];
}

- (void)didPressClose
{
    [self.delegate trophyEditorDidSelectCancel];
}

- (void)didPressSend
{
    [self.delegate trophyEditorDidSelectSend];
}

- (NSString *)caption
{
    return self.captionTextField.text;
}

#pragma mark - UIGestureRecognizer Delegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.captionTextField.text length] > 0) {
        self.sendButton.enabled = YES;
        self.sendButton.hidden = NO;
    } else {
        self.sendButton.enabled = NO;
        self.sendButton.hidden = YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]){
        return NO;
    } else {
        if ([self.captionTextField isFirstResponder]) {
            if ([self.captionTextField.text length] == 0) {
                self.captionTextField.hidden = YES;
            }
            [self.captionTextField resignFirstResponder];
        } else {
            self.descriptionLabel.hidden = NO;
            self.backgroundView.hidden = NO;
            self.captionTextField.hidden = NO;
            [self.captionTextField becomeFirstResponder];
        }
    }
    return NO;
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 20, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 20, 0);
}

@end
