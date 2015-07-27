//
//  TAUser.m
//  Trophy
//
//  Created by Gigster on 12/30/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import "TAUser.h"

#import "TAAddSettingsView.h"
#import "TAGroup.h"

@interface TAUser ()

@property (nonatomic, strong) PFUser *storedUser;
@property (nonatomic, strong) NSArray *parseGroups;
@property (nonatomic, strong) PFFile *profileImageFile;

@end

@implementation TAUser

- (instancetype)initWithStoredUser:(PFUser *)storedUser
{
    self = [super init];
    if (self) {
        _storedUser = storedUser;
        self.username = storedUser.username;
        self.password = storedUser.password;
        self.phoneNumber = storedUser[@"phone"];
        self.name = storedUser[@"name"];
        self.bio = storedUser[@"bio"];
        self.groups = [self processGroups:storedUser[@"groups"]];
        
        if (storedUser[@"profileImage"]) {
            self.profileImageFile = storedUser[@"profileImage"];
            [self.profileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    self.profileImage = [UIImage imageWithData:data];
                }
            }];
        }
    }
    return self;
}

- (NSArray *)processGroups:(NSArray *)parseGroups
{
    if ([parseGroups count] > 0) {
        id parseGroup = parseGroups[0];
        if ([parseGroup isKindOfClass:[PFObject class]]) {
            PFObject *checkGroup = (PFObject *)parseGroup;
            if ([checkGroup isDataAvailable]) {
                NSMutableArray *groups = [NSMutableArray array];
                for (PFObject *group in parseGroups) {
                    [groups addObject:[[TAGroup alloc] initWithStoredGroup:group]];
                }
                return groups;
            }
        }
    }
    return nil;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"groups"]) {
        NSMutableArray *parseGroups = [NSMutableArray array];
        NSMutableArray *userGroups = [NSMutableArray array];
        for (id group in value) {
            if ([group isKindOfClass:[TAGroup class]]) {
                TAGroup *currentGroup = (TAGroup *)group;
                [userGroups addObject:currentGroup];
                [parseGroups addObject:[currentGroup getGroupAsParseObject]];
            } else if ([group isKindOfClass:[PFObject class]]) {
                PFObject *currentGroup = (PFObject *)group;
                [userGroups addObject:[[TAGroup alloc] initWithStoredGroup:currentGroup]];
                [parseGroups addObject:currentGroup];
            } else {
                return;
            }
        }
        [self.storedUser setObject:parseGroups forKey:@"groups"];
        self.groups = userGroups;
    } else if ([key isEqualToString:@"profileImage"]) {
        self.storedUser[@"profileImage"] = value;
        self.profileImageFile = value;
        [self.profileImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                self.profileImage = [UIImage imageWithData:data];
            }
        }];
    } else {
        [self.storedUser setObject:value forKey:key];
        [super setValue:value forKey:key];
    }
}

- (PFUser *)getUserAsParseObject
{
    return self.storedUser;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.groups = [decoder decodeObjectForKey:@"groups"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    NSMutableArray *groups = [NSMutableArray array];
    for (id group in self.groups) {
        if ([group isKindOfClass:[TAGroup class]]) {
            [groups addObject:(TAGroup *)group];
        } else if ([group isKindOfClass:[PFObject class]]) {
            [groups addObject:[[TAGroup alloc] initWithStoredGroup:(PFObject *)group]];
        }
    }
    [encoder encodeObject:groups forKey:@"groups"];
}

- (BOOL)isEqualToUser:(TAUser *)user
{
    if (user) {
        PFUser *parseSelf = [self getUserAsParseObject];
        PFUser *parseOther = [user getUserAsParseObject];
        if ([parseSelf.objectId isEqualToString:parseOther.objectId]) {
            return YES;
        }
    }
    return NO;
}

- (PFFile *)parseFileForProfileImage
{
    return self.profileImageFile;
}

@end
