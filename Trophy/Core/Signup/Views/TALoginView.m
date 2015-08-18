//
//  TALoginView.m
//  Trophy
//
//  Created by Gigster on 1/2/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TALoginView.h"

#import "UIColor+TAAdditions.h"
#import "UITextField+TAAdditions.h"

static const CGFloat kLoginButtonHeight = 40.0;
static const CGFloat kLoginButtonWidth = 150.0;

static const CGFloat kLoginTextFieldHeight = 35.0;
static const CGFloat kLoginTextFieldVerticalMargin = 20.0;

static const CGFloat kContinueButtonWidth = 150.0;
static const CGFloat kContinueButtonHeight = 40.0;

@interface TALoginView () <UITextFieldDelegate>

@property (nonatomic, strong) UIButton *usernameButton;
@property (nonatomic, strong) UIButton *phoneNumberButton;
@property (nonatomic, strong) UIColor *buttonSelectedColor;
@property (nonatomic, strong) UIColor *buttonUnselectedColor;

@property (nonatomic, strong) UITextField *usernameInput;
@property (nonatomic, strong) UITextField *phoneNumberInput;
@property (nonatomic, strong) UITextField *passwordInput;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation TALoginView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor trophyNavyColor];
        self.buttonSelectedColor = [UIColor darkerBlueColor];
        self.buttonUnselectedColor = [UIColor unselectedGrayColor];
        
        _usernameButton = [[UIButton alloc] init];
        [self.usernameButton setTitle:@"Username" forState:UIControlStateNormal];
        [self.usernameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.usernameButton setBackgroundColor:self.buttonSelectedColor];
        self.usernameButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.usernameButton.font = [UIFont fontWithName:@"Avenir-Heavy" size:17.0];
        [self.usernameButton addTarget:self action:@selector(usernameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.usernameButton];
        self.usernameButton.selected = YES;
        
        _phoneNumberButton = [[UIButton alloc] init];
        [self.phoneNumberButton setTitle:@"Phone Number" forState:UIControlStateNormal];
        [self.phoneNumberButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.phoneNumberButton setBackgroundColor:self.buttonUnselectedColor];
        self.phoneNumberButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.phoneNumberButton.font = [UIFont fontWithName:@"Avenir-Heavy" size:17.0];
        [self.phoneNumberButton addTarget:self action:@selector(phoneNumberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.phoneNumberButton];
        
        _usernameInput = [TATextField textFieldTranslucent];
        self.usernameInput.delegate = self;
        self.usernameInput.placeholder = @"Username";
        self.usernameInput.font = [UIFont fontWithName:@"Avenir-Book" size:13.0];
        self.usernameInput.backgroundColor = [UIColor whiteColor];
        self.usernameInput.returnKeyType = UIReturnKeyNext;
        [self addSubview:self.usernameInput];

        _phoneNumberInput = [TAPhoneNumberField textFieldTranslucent];
        self.phoneNumberInput.placeholder = @"Phone Number";
        self.phoneNumberInput.keyboardType = UIKeyboardTypePhonePad;
        [self addSubview:self.phoneNumberInput];
        self.phoneNumberInput.backgroundColor = [UIColor whiteColor];
        self.phoneNumberInput.font = [UIFont fontWithName:@"Avenir-Book" size:13.0];
        self.phoneNumberInput.hidden = YES;
        self.phoneNumberInput.enabled = NO;

        _passwordInput = [TATextField textFieldTranslucent];
        self.passwordInput.delegate = self;
        self.passwordInput.secureTextEntry = YES;
        self.passwordInput.placeholder = @"Password";
        self.passwordInput.font = [UIFont fontWithName:@"Avenir-Book" size:13.0];

        self.passwordInput.backgroundColor = [UIColor whiteColor];
        self.passwordInput.returnKeyType = UIReturnKeyNext;
        [self addSubview:self.passwordInput];

        _continueButton = [[UIButton alloc] init];
        [self.continueButton setTitle:@"Login" forState:UIControlStateNormal];
        [self.continueButton setTitleColor:[UIColor trophyNavyColor] forState:UIControlStateNormal];
        self.continueButton.backgroundColor = [UIColor trophyYellowColor];
        self.continueButton.layer.cornerRadius = 5.0;
        self.continueButton.font = [UIFont fontWithName:@"Avenir-Heavy" size:18.0];
        self.continueButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.continueButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.continueButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [self.usernameButton sizeToFit];
    CGRect frame = self.usernameButton.frame;
    frame.size.width = CGRectGetMidX(self.bounds);
    frame.size.height = kLoginButtonHeight;
    frame.origin.x = CGRectGetMinX(self.bounds);
    frame.origin.y = CGRectGetMinY(self.bounds) + (kLoginButtonHeight * 2) - 16.5;
    self.usernameButton.frame = frame;
    
    [self.phoneNumberButton sizeToFit];
    frame = self.phoneNumberButton.frame;
    frame.size.width = CGRectGetMidX(self.bounds);
    frame.size.height = kLoginButtonHeight;
    frame.origin.x = CGRectGetMidX(self.bounds);
    frame.origin.y = CGRectGetMinY(self.bounds) + (kLoginButtonHeight * 2) - 16.5;
    self.phoneNumberButton.frame = frame;
    
    frame = self.usernameInput.frame;
    frame.size.width = CGRectGetWidth(self.bounds) - 100.0;
    frame.size.height = kLoginTextFieldHeight;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - frame.size.width) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.usernameButton.frame) + kLoginTextFieldVerticalMargin * 2;
    self.usernameInput.frame = frame;
    
    frame = self.phoneNumberInput.frame;
    frame.size.width = CGRectGetWidth(self.bounds) - 100.0;
    frame.size.height = kLoginTextFieldHeight;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - frame.size.width) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.usernameButton.frame) + kLoginTextFieldVerticalMargin * 2;
    self.phoneNumberInput.frame = frame;

    frame = self.passwordInput.frame;
    frame.size.width = CGRectGetWidth(self.bounds) - 100.0;
    frame.size.height = kLoginTextFieldHeight;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - frame.size.width) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.usernameInput.frame) + kLoginTextFieldVerticalMargin;
    self.passwordInput.frame = frame;

    [self.continueButton sizeToFit];
    frame = self.continueButton.frame;
    frame.size.width = kContinueButtonWidth;
    frame.size.height = kContinueButtonHeight;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - kContinueButtonWidth) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.passwordInput.frame) + kLoginTextFieldVerticalMargin * 2;
    self.continueButton.frame = frame;
}

- (void)usernameButtonPressed:(id)sender
{
    if (self.usernameButton.selected == NO) {
        self.usernameButton.selected = YES;
        self.phoneNumberButton.selected = NO;
        self.usernameButton.backgroundColor = self.buttonSelectedColor;
        self.phoneNumberButton.backgroundColor = self.buttonUnselectedColor;
        
        [self enableUsernameInput:YES];
    }
}

- (void)phoneNumberButtonPressed:(id)sender
{
    if (self.phoneNumberButton.selected == NO) {
        self.phoneNumberButton.selected = YES;
        self.usernameButton.selected = NO;
        self.phoneNumberButton.backgroundColor = self.buttonSelectedColor;
        self.usernameButton.backgroundColor = self.buttonUnselectedColor;
        
        [self enableUsernameInput:NO];
    }
}

- (void)enableUsernameInput:(BOOL)enabled
{
    self.usernameInput.hidden = (enabled == NO);
    self.usernameInput.enabled = enabled;
    self.phoneNumberInput.hidden = enabled;
    self.phoneNumberInput.enabled = (enabled == NO);
}

- (void)loginButtonPressed
{
    [self.delegate loginViewDidPressContinue:self];
}

- (BOOL)usernameSelected
{
    return self.usernameButton.selected;
}

- (NSString *)username
{
    return self.usernameInput.text;
}

- (NSString *)phoneNumber
{
    return self.phoneNumberInput.text;
}

- (NSString *)password
{
    return self.passwordInput.text;
}

- (BOOL)validateLogin
{
    if ([self usernameSelected]) {
        return [self.username length] > 0 && [self.password length] > 0;
    } else {
        return [self.phoneNumber length] > 0 && [self.password length] > 0;
    }
}

- (void)startAnimating
{
    self.continueButton.enabled = NO;
    [self.continueButton setTitle:@"" forState:UIControlStateNormal];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicator.backgroundColor = [UIColor clearColor];
    CGRect frame = self.activityIndicator.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.continueButton.frame) - frame.size.width) / 2.0);
    frame.origin.y = floorf((CGRectGetHeight(self.continueButton.frame) - frame.size.height) / 2.0);
    self.activityIndicator.frame = frame;
    [self.continueButton addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)stopAnimating
{
    if (self.activityIndicator.isAnimating) {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
        [self.continueButton setTitle:@"Let's get started" forState:UIControlStateNormal];
        self.continueButton.enabled = YES;
    }
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameInput || textField == self.phoneNumberInput) {
        [self.passwordInput becomeFirstResponder];
    } else {
        [self loginButtonPressed];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UIView *view in self.subviews){
        if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder]) {
            [view resignFirstResponder];
        }
    }
}

@end
