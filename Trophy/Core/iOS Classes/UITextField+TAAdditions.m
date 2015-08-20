//
//  UITextField+TAAdditions.m
//  Trophy
//
//  Created by Gigster on 2/9/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "UITextField+TAAdditions.h"

#import "UIColor+TAAdditions.h"

@implementation TATextField

+ (TATextField *)textFieldWithYellowBorder
{
    TATextField *signupTextField = [[TATextField alloc] init];
    signupTextField.textColor = [UIColor grayColor];
    signupTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    signupTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    signupTextField.layer.cornerRadius = 5.0;
    signupTextField.layer.borderColor = [UIColor trophyYellowColor].CGColor;
    signupTextField.layer.borderWidth = 1.0;
    signupTextField.layer.masksToBounds = YES;
    return signupTextField;
}

+ (TATextField *)textFieldTranslucent
{
    TATextField *translucentTextField = [[TATextField alloc] init];
    translucentTextField.textColor = [UIColor trophyNavyColor];
    translucentTextField.backgroundColor = [UIColor mediumTranslucentWhite];
    translucentTextField.layer.cornerRadius = 5.0;
    translucentTextField.layer.masksToBounds = YES;
    translucentTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    translucentTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [translucentTextField setValue:[UIColor highTranslucentWhite] forKeyPath:@"_placeholderLabel.textColor"];
    return translucentTextField;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect newBounds = bounds;
    newBounds.size.width = bounds.size.width - 15.0;
    return CGRectInset(newBounds, 10, 10);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect newBounds = bounds;
    newBounds.size.width = bounds.size.width - 15.0;
    return CGRectInset(newBounds, 10, 10);
}

@end

@implementation TAPhoneNumberField

+ (TAPhoneNumberField *)textFieldWithYellowBorder
{
    TAPhoneNumberField *phoneNumberField = [[TAPhoneNumberField alloc] init];
    phoneNumberField.textColor = [UIColor grayColor];
    phoneNumberField.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneNumberField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    phoneNumberField.layer.cornerRadius = 5.0;
    phoneNumberField.layer.borderColor = [UIColor trophyYellowColor].CGColor;
    phoneNumberField.layer.borderWidth = 1.0;
    phoneNumberField.layer.masksToBounds = YES;
    phoneNumberField.delegate = phoneNumberField;
    return phoneNumberField;
}

+ (TAPhoneNumberField *)textFieldTranslucent
{
    TAPhoneNumberField *translucentTextField = [[TAPhoneNumberField alloc] init];
    translucentTextField.textColor = [UIColor trophyNavyColor];
    translucentTextField.backgroundColor = [UIColor mediumTranslucentWhite];
    translucentTextField.layer.cornerRadius = 5.0;
    translucentTextField.layer.masksToBounds = YES;
    translucentTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    translucentTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    translucentTextField.delegate = translucentTextField;
    [translucentTextField setValue:[UIColor highTranslucentWhite] forKeyPath:@"_placeholderLabel.textColor"];
    return translucentTextField;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect newBounds = bounds;
    newBounds.size.width = bounds.size.width - 15.0;
    return CGRectInset(newBounds, 10, 10);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect newBounds = bounds;
    newBounds.size.width = bounds.size.width - 15.0;
    return CGRectInset(newBounds, 10, 10);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.backgroundColor = [UIColor whiteColor];
}

- (NSString *)formatPhoneNumber:(NSString *)number {
    if ([number length] == 0) return @"";
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    number = [regex stringByReplacingMatchesInString:number options:0 range:NSMakeRange(0, [number length]) withTemplate:@""];
    
    if ([number length] > 10) {
        number = [number substringToIndex:10];
    }
    
    // Format the number to match: (123) 456-7890
    if ([number length] < 7) {
        number = [number stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
                                                   withString:@"($1) $2"
                                                      options:NSRegularExpressionSearch
                                                        range:NSMakeRange(0, [number length])];
    } else {
        number = [number stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                   withString:@"($1) $2-$3"
                                                      options:NSRegularExpressionSearch
                                                        range:NSMakeRange(0, [number length])];
    }
    return number;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string length] == 0) {
        NSRange newRange = range;
        NSString *replacementString = string;
        NSString *subString = [textField.text substringWithRange:range];
        NSRange digits = [subString rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
        if (digits.location == NSNotFound) {
            for (int i = (int)range.location - 1; i >= 0; i--) {
                if (isdigit([textField.text characterAtIndex:i])) {
                    newRange = NSMakeRange(i, range.length + (range.location - i));
                    replacementString = @"";
                    break;
                }
            }
        }
        NSString *originalString = textField.text;
        NSString *totalString = [textField.text stringByReplacingCharactersInRange:newRange withString:replacementString];
        textField.text = [self formatPhoneNumber:totalString];
        NSInteger cursorOffset = newRange.location;
        if ([originalString length] == 7 && [textField.text length] < 7) {
            if (range.location == 6) {
                cursorOffset = [textField.text length];
            } else {
                cursorOffset -= 1;
            }
        } else if (newRange.location > [textField.text length]) {
            cursorOffset = [textField.text length];
        }
        UITextPosition *cursorPosition = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
        UITextRange *selectedRange = [textField textRangeFromPosition:cursorPosition toPosition:cursorPosition];
        [textField setSelectedTextRange:selectedRange];
        return NO;
    } else {
        NSString *originalString = textField.text;
        NSString *totalString;
        if (range.location == [textField.text length]) {
            totalString = [NSString stringWithFormat:@"%@%@", textField.text, string];
        } else {
            NSString *originalString = textField.text;
            totalString = [originalString stringByReplacingCharactersInRange:range withString:string];
        }
        textField.text = [self formatPhoneNumber:totalString];
        
        NSInteger cursorOffset = range.location + [string length];
        if (range.location == [originalString length]) {
            cursorOffset = [textField.text length];
        } else {
            if ([textField.text length] > 7 && range.location == 4) {
                cursorOffset = range.location + [string length] + 2;
            } else if ([textField.text length] > 11 && range.location == 9) {
                cursorOffset = range.location + [string length] + 1;
            }
        }
        UITextPosition *cursorPosition = [textField positionFromPosition:textField.beginningOfDocument offset:cursorOffset];
        UITextRange *selectedRange = [textField textRangeFromPosition:cursorPosition toPosition:cursorPosition];
        [textField setSelectedTextRange:selectedRange];
        return NO;
    }
}

@end
