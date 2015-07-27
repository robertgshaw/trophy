//
//  TAGroup.h
//  Trophy
//
//  Created by Gigster on 12/30/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Parse/Parse.h>

@interface TAGroup : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *inviteCode;

- (instancetype)initWithStoredGroup:(PFObject *)group;
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;
- (PFObject *)getGroupAsParseObject;

@end
