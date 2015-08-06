//
//  TASignupView.m
//  Trophy
//
//  Created by Gigster on 12/10/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import "TASignupView.h"

#import "UIColor+TAAdditions.h"
#import "UITextField+TAAdditions.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

static const CGFloat kSignupTextFieldHeight = 35.0;
static const CGFloat kSignupTextFieldVerticalMargin = 20.0;

static const CGFloat kContinueButtonWidth = 150.0;
static const CGFloat kContinueButtonHeight = 40.0;


@interface TASignupView () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) TATextField *usernameInput;
@property (nonatomic, strong) TATextField *passwordInput;
@property (nonatomic, strong) TAPhoneNumberField *phoneNumberInput;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *privacyButton;
@property (nonatomic, strong) UIButton *legalButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation TASignupView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        _logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        [self addSubview:self.logoImageView];
        
        _titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = @"Trophy";
        self.titleLabel.font = [UIFont boldSystemFontOfSize:30.0];
        self.titleLabel.textColor = [UIColor trophyYellowColor];
        [self addSubview:self.titleLabel];

        _usernameInput = [TATextField textFieldWithYellowBorder];
        self.usernameInput.delegate = self;
        self.usernameInput.placeholder = @"Username";
        self.usernameInput.returnKeyType = UIReturnKeyNext;
        [self addSubview:self.usernameInput];

        _passwordInput = [TATextField textFieldWithYellowBorder];
        self.passwordInput.delegate = self;
        self.passwordInput.secureTextEntry = YES;
        self.passwordInput.placeholder = @"Password";
        self.passwordInput.returnKeyType = UIReturnKeyNext;
        [self addSubview:self.passwordInput];

        _phoneNumberInput = [TAPhoneNumberField textFieldWithYellowBorder];
        self.phoneNumberInput.placeholder = @"Phone Number";
        self.phoneNumberInput.returnKeyType = UIReturnKeyDone;
        self.phoneNumberInput.keyboardType = UIKeyboardTypePhonePad;
        [self addSubview:self.phoneNumberInput];

        _continueButton = [[UIButton alloc] init];
        [self.continueButton setTitle:@"Let's get started" forState:UIControlStateNormal];
        [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.continueButton.backgroundColor = [UIColor trophyYellowColor];
        self.continueButton.layer.cornerRadius = 5.0;
        self.continueButton.layer.borderWidth = 1.0;
        self.continueButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.continueButton addTarget:self action:@selector(continueButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.continueButton];

        _loginButton = [[UIButton alloc] init];
        [self.loginButton setTitle:@" Login " forState:UIControlStateNormal];
        [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.loginButton.backgroundColor = [UIColor trophyYellowColor];
        self.loginButton.layer.cornerRadius = 5.0;
        [self.loginButton setTitleColor:[UIColor colorWithRed:0.812 green:0.82 blue:0.82 alpha:1] forState:UIControlStateHighlighted];
        [self.loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.loginButton];
        
        _privacyButton = [[UIButton alloc] init];
        [self.privacyButton setTitle:@"Privacy Policy" forState:UIControlStateNormal];
        [self.privacyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.privacyButton setTitleColor:[UIColor colorWithRed:0.812 green:0.82 blue:0.82 alpha:1] forState:UIControlStateHighlighted];
        [self.privacyButton addTarget:self action:@selector(privacyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.privacyButton];
        
        _legalButton = [[UIButton alloc] init];
        [self.legalButton setTitle:@"Legal Terms" forState:UIControlStateNormal];
        [self.legalButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.legalButton setTitleColor:[UIColor colorWithRed:0.812 green:0.82 blue:0.82 alpha:1] forState:UIControlStateHighlighted];
        [self.legalButton addTarget:self action:@selector(legalButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.legalButton];
    }
    return self;
}

- (void)layoutSubviews
{
    
    CGRect frame = self.logoImageView.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.logoImageView.frame)) / 2.0);
    frame.origin.y = floorf(CGRectGetHeight(self.bounds) / 1.8);
    self.logoImageView.frame = frame;
    
    [self.titleLabel sizeToFit];
    frame = self.titleLabel.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.titleLabel.frame)) / 2.0);
    frame.origin.y = floorf(CGRectGetHeight(self.bounds) / 50.0) + 10.0;
    self.titleLabel.frame = frame;

    frame = self.usernameInput.frame;
    frame.size.width = CGRectGetWidth(self.bounds) - 100.0;
    frame.size.height = kSignupTextFieldHeight;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - frame.size.width) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.titleLabel.frame) + kSignupTextFieldVerticalMargin;
    self.usernameInput.frame = frame;

    frame = self.passwordInput.frame;
    frame.size.width = CGRectGetWidth(self.bounds) - 100.0;
    frame.size.height = kSignupTextFieldHeight;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - frame.size.width) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.usernameInput.frame) + kSignupTextFieldVerticalMargin;
    self.passwordInput.frame = frame;

    frame = self.phoneNumberInput.frame;
    frame.size.width = CGRectGetWidth(self.bounds) - 100.0;
    frame.size.height = kSignupTextFieldHeight;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - frame.size.width) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.passwordInput.frame) + kSignupTextFieldVerticalMargin;
    self.phoneNumberInput.frame = frame;

    [self.continueButton sizeToFit];
    frame = self.continueButton.frame;
    frame.size.width = kContinueButtonWidth;
    frame.size.height = kContinueButtonHeight;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - kContinueButtonWidth) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.phoneNumberInput.frame) + kSignupTextFieldVerticalMargin + 10.0;
    self.continueButton.frame = frame;

    [self.loginButton sizeToFit];
    frame = self.loginButton.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.loginButton.frame)) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.logoImageView.frame) + 12.5;
    self.loginButton.frame = frame;
    
    [self.privacyButton sizeToFit];
    frame = self.privacyButton.frame;
    frame.origin.x = CGRectGetMinX(self.phoneNumberInput.frame);
    frame.origin.y = CGRectGetMaxY(self.loginButton.frame) + 12.5;
    self.privacyButton.frame = frame;
    
    [self.legalButton sizeToFit];
    frame = self.legalButton.frame;
    frame.origin.x = CGRectGetMaxX(self.privacyButton.frame) + 12.5;
    frame.origin.y = CGRectGetMaxY(self.loginButton.frame) + 12.5;
    self.legalButton.frame = frame;
}

- (void)continueButtonPressed
{
    [self.delegate signupViewDidPressContinueButton];
}

- (void)loginButtonPressed
{
    [self.delegate signupViewDidPressLoginButton];
}
- (void)privacyButtonPressed
{
    [self.delegate signupViewDidPressPrivacyButton];
}
- (void)legalButtonPressed
{
    [self.delegate signupViewDidPressLegalButton];

}
- (TAUser *)user
{
    if (_user == nil) {
        _user = [[TAUser alloc] init];
    }
    _user.username = self.usernameInput.text;
    _user.password = self.passwordInput.text;
    NSString *number = [[self.phoneNumberInput.text componentsSeparatedByCharactersInSet:
                         [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                        componentsJoinedByString:@""];
    _user.phoneNumber = number;
    return _user;
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

#pragma mark - Validation Methods

- (BOOL)signupIsValid
{
    BOOL isValid = YES;
    if ([self validUsername] == NO) {
        isValid = NO;
        self.usernameInput.backgroundColor = [UIColor redColor];
    } else {
        self.usernameInput.backgroundColor = [UIColor whiteColor];
    }

    if ([self validPassword] == NO) {
        isValid = NO;
        self.passwordInput.backgroundColor = [UIColor redColor];
    } else {
        self.passwordInput.backgroundColor = [UIColor whiteColor];
    }

    if ([self validPhoneNumber] == NO) {
        isValid = NO;
        self.phoneNumberInput.backgroundColor = [UIColor redColor];
    } else {
        self.phoneNumberInput.backgroundColor = [UIColor whiteColor];
    }

    return isValid;
}

- (NSString *)signupError
{
    if ([self signupIsValid]) {
        return nil;
    }
    if ([self validUsername] == NO) {
        return @"Username must be 3 or more characters";
    } else if ([self validPassword] == NO) {
        return @"Password must be 8 or more characters";
    } else if ([self validPhoneNumber] == NO) {
        return @"That doesn't look like a phone number!";
    }
    return nil;
}

- (BOOL)validUsername
{
    return ([self.usernameInput.text length] >= 3);
}

- (BOOL)validPassword
{
    return ([self.passwordInput.text length] >= 8);
}

- (BOOL)validPhoneNumber
{
    NSString *number = self.phoneNumberInput.text;
    if ([number length] == 14) {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\([0-9]{3}\\) [0-9]{3}-[0-9]{4}$" options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult *match = [regex firstMatchInString:number options:0 range:NSMakeRange(0, [number length])];
        if (match) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.usernameInput) {
        self.usernameInput.backgroundColor = [UIColor whiteColor];
    } else if (textField == self.passwordInput) {
        self.passwordInput.backgroundColor = [UIColor whiteColor];
    } else if (textField == self.phoneNumberInput) {
        self.phoneNumberInput.backgroundColor = [UIColor whiteColor];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *totalString;
    if (range.location == [textField.text length]) {
        totalString = [NSString stringWithFormat:@"%@%@", textField.text, string];
    } else {
        NSString *originalString = textField.text;
        totalString = [originalString stringByReplacingCharactersInRange:range withString:string];
    }
    NSDictionary *attributes = @{NSForegroundColorAttributeName:textField.textColor, NSFontAttributeName:textField.font};
    CGRect stringSize = [totalString boundingRectWithSize:self.bounds.size
                                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               attributes:attributes context:nil];
    
    if (stringSize.size.width >= [textField editingRectForBounds:textField.bounds].size.width) {
        textField.textAlignment = NSTextAlignmentRight;
    } else {
        textField.textAlignment = NSTextAlignmentLeft;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameInput) {
        [self.passwordInput becomeFirstResponder];
    } else if (textField == self.passwordInput) {
        [self.phoneNumberInput becomeFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.textAlignment = NSTextAlignmentLeft;
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
