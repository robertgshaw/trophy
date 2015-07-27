//
//  TAFriendContact.h
//  Trophy
//
//  Created by Gigster on 1/26/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAFriendContact : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSArray *phoneNumbers;
@property (nonatomic, strong) NSArray *phoneNumberLabels;

@end
