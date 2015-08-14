//
//  TAJoinGroupView.m
//  Trophy
//
//  Created by Gigster on 1/30/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAJoinGroupView.h"

#import "UIColor+TAAdditions.h"
#import "UITextField+TAAdditions.h"

static const CGFloat kJoinGroupTextFieldHeight = 35.0;
static const CGFloat kJoinGroupVerticalMargin = 30.0;

@interface TAJoinGroupView () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *joinGroupImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) TATextField *groupNameInput;
@property (nonatomic, strong) TATextField *inviteCodeInput;

@end

@implementation TAJoinGroupView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _joinGroupImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"join-group-logo"]];
        [self addSubview:self.joinGroupImageView];
        
        self.backgroundColor = [UIColor trophyNavyColor];
        
        _titleLabel = [[UILabel alloc] init];
        [self.titleLabel setText:@"Group Info"];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        self.titleLabel.textColor = [UIColor trophyYellowColor];
        self.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:22.0];
        [self addSubview:self.titleLabel];
        
        
//        _groupNameInput = [TATextField textFieldWithYellowBorder];
//        self.groupNameInput.delegate = self;
//        self.groupNameInput.placeholder = @"Group name";
//        self.groupNameInput.borderStyle = UITextBorderStyleRoundedRect;
//        self.groupNameInput.clearButtonMode = UITextFieldViewModeWhileEditing;
//        self.groupNameInput.autocapitalizationType = UITextAutocapitalizationTypeWords;
//        self.groupNameInput.returnKeyType = UIReturnKeyNext;
//        [self addSubview:self.groupNameInput];
        
         
        _inviteCodeInput = [TATextField textFieldWithYellowBorder];
        self.inviteCodeInput.delegate = self;
        self.inviteCodeInput.placeholder = @"Invite Code";
        self.inviteCodeInput.font = [UIFont fontWithName:@"Avenir-Book" size:15.0];
        self.inviteCodeInput.borderStyle = UITextBorderStyleRoundedRect;
        self.inviteCodeInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.inviteCodeInput.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        self.inviteCodeInput.returnKeyType = UIReturnKeyDone;
        [self addSubview:self.inviteCodeInput];
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect frame = self.joinGroupImageView.frame;
    frame.origin.x = CGRectGetMidX(self.bounds) - floorf(CGRectGetWidth(self.joinGroupImageView.frame) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.inviteCodeInput.frame) + kJoinGroupVerticalMargin;
    self.joinGroupImageView.frame = frame;
    
    [self.titleLabel sizeToFit];
    frame = self.titleLabel.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.titleLabel.frame)) / 2.0);
    frame.origin.y = 60.0;
    self.titleLabel.frame = frame;
    
    frame = self.inviteCodeInput.frame;
    frame.size.width = CGRectGetWidth(self.bounds) - 100.0;
    frame.size.height = kJoinGroupTextFieldHeight;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - frame.size.width) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.titleLabel.frame) + kJoinGroupVerticalMargin;
    self.inviteCodeInput.frame = frame;
    
//    frame = self.groupNameInput.frame;
//    frame.size.width = CGRectGetWidth(self.bounds) - 100.0;
//    frame.size.height = kJoinGroupTextFieldHeight;
//    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - frame.size.width) / 2.0);
//    frame.origin.y = CGRectGetMaxY(self.titleLabel.frame) + kJoinGroupVerticalMargin;
//    self.groupNameInput.frame = frame;
}

//- (NSString *)groupName
//{
//    return self.groupNameInput.text;
//}

- (NSString *)inviteCode
{
    return self.inviteCodeInput.text;
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    // UITextField *remainingTextField = (textField == self.groupNameInput) ? self.inviteCodeInput : self.groupNameInput;
    if ([updatedString length] > 0) {
        [self.delegate joinGroupViewShouldShowJoinButton:self enabled:YES];
    } else {
        [self.delegate joinGroupViewShouldShowJoinButton:self enabled:NO];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.delegate joinGroupViewShouldShowJoinButton:self enabled:NO];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    if (textField == self.groupNameInput) {
//        [self.inviteCodeInput becomeFirstResponder];
//    } else {
//        [self.delegate joinGroupViewDidFinishEnteringInformation:self];
//    }

    [self.delegate joinGroupViewDidFinishEnteringInformation:self];
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
