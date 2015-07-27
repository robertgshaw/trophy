//
//  TACreateGroupView.m
//  Trophy
//
//  Created by Gigster on 1/24/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TACreateGroupView.h"

#import "UIColor+TAAdditions.h"
#import "UITextField+TAAdditions.h"

static const CGFloat kCreateGroupTextFieldHeight = 35.0;
static const CGFloat kCreateGroupVerticalMargin = 20.0;

@interface TACreateGroupView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *createTrophyImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) TATextField *groupNameInput;
@property (nonatomic, strong) TATextField *maxGroupSizeInput;

@end

@implementation TACreateGroupView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _createTrophyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"create-group-logo"]];
        [self addSubview:self.createTrophyImageView];
        
        _titleLabel = [[UILabel alloc] init];
        [self.titleLabel setText:@"Group Info"];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        self.titleLabel.textColor = [UIColor trophyYellowColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
        [self addSubview:self.titleLabel];
        
        _groupNameInput = [TATextField textFieldWithYellowBorder];
        self.groupNameInput.delegate = self;
        self.groupNameInput.placeholder = @"Group name";
        self.groupNameInput.borderStyle = UITextBorderStyleRoundedRect;
        self.groupNameInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.groupNameInput.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.groupNameInput.returnKeyType = UIReturnKeyNext;
        [self addSubview:self.groupNameInput];
        
        _maxGroupSizeInput = [TATextField textFieldWithYellowBorder];
        self.maxGroupSizeInput.delegate = self;
        self.maxGroupSizeInput.placeholder = @"Minimum group size";
        self.maxGroupSizeInput.borderStyle = UITextBorderStyleRoundedRect;
        self.maxGroupSizeInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.maxGroupSizeInput.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        self.maxGroupSizeInput.returnKeyType = UIReturnKeyDone;
        self.maxGroupSizeInput.keyboardType = UIKeyboardTypeNumberPad;
        [self addSubview:self.maxGroupSizeInput];
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect frame = self.createTrophyImageView.frame;
    frame.origin.x = CGRectGetMidX(self.bounds) - floorf(CGRectGetWidth(self.createTrophyImageView.frame) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.maxGroupSizeInput.frame) + kCreateGroupVerticalMargin;
    self.createTrophyImageView.frame = frame;
    
    [self.titleLabel sizeToFit];
    frame = self.titleLabel.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.titleLabel.frame)) / 2.0);
    frame.origin.y = 40.0; //CGRectGetMaxY(self.createTrophyImageView.frame) + kCreateGroupVerticalMargin;
    self.titleLabel.frame = frame;
    
    frame = self.groupNameInput.frame;
    frame.size.width = CGRectGetWidth(self.bounds) - 100.0;
    frame.size.height = kCreateGroupTextFieldHeight;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - frame.size.width) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.titleLabel.frame) + kCreateGroupVerticalMargin;
    self.groupNameInput.frame = frame;
    
    frame = self.maxGroupSizeInput.frame;
    frame.size.width = CGRectGetWidth(self.bounds) - 100.0;
    frame.size.height = kCreateGroupTextFieldHeight;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - frame.size.width) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.groupNameInput.frame) + kCreateGroupVerticalMargin;
    self.maxGroupSizeInput.frame = frame;
}

- (NSString *)groupName
{
    return self.groupNameInput.text;
}

- (NSInteger)maxGroupSize
{
    return [self.maxGroupSizeInput.text intValue];
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    UITextField *remainingTextField = (textField == self.groupNameInput) ? self.maxGroupSizeInput : self.groupNameInput;
    if ([updatedString length] > 0 && [remainingTextField.text length] > 0) {
        [self.delegate createGroupViewShouldShowNextButton:self enabled:YES];
    } else {
        [self.delegate createGroupViewShouldShowNextButton:self enabled:NO];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.delegate createGroupViewShouldShowNextButton:self enabled:NO];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.groupNameInput) {
        [self.maxGroupSizeInput becomeFirstResponder];
    } else {
        [self.delegate createGroupViewDidFinishEnteringInformation:self];
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
