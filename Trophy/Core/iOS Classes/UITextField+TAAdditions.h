//
//  UITextField+TAAdditions.h
//  Trophy
//
//  Created by Gigster on 2/9/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TATextField : UITextField

+ (TATextField *)textFieldWithYellowBorder;

@end

@interface TAPhoneNumberField : TATextField<UITextFieldDelegate>

+ (TAPhoneNumberField *)textFieldWithYellowBorder;

@end