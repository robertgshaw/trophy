//
//  TAFriendContact.m
//  Trophy
//
//  Created by Gigster on 1/26/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAFriendContact.h"

@implementation TAFriendContact

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _fullName = dict[@"fullName"];
        _firstName = dict[@"firstName"];
        _phoneNumbers = dict[@"phoneNumbers"];
        _phoneNumberLabels = dict[@"phoneNumberLabels"];
    }
    return self;
}

@end
