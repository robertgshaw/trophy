//
//  TAGroup.m
//  Trophy
//
//  Created by Gigster on 12/30/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import "TAGroup.h"

#import "TAUser.h"

@interface TAGroup ()

@property (nonatomic, strong) PFObject *parseGroup;

@end

@implementation TAGroup

- (instancetype)initWithStoredGroup:(PFObject *)group
{
    self = [super init];
    if (self) {
        _name = group[@"name"];
        _users = group[@"users"];
        _groupId = group.objectId;
        _inviteCode = group[@"inviteCode"];
        _parseGroup = group;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.groupId = [decoder decodeObjectForKey:@"groupId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.groupId forKey:@"groupId"];
}

- (PFObject *)getGroupAsParseObject
{
    return self.parseGroup;
}

@end
