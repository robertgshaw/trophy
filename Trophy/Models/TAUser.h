//
//  TAUser.h
//  Trophy
//
//  Created by Gigster on 12/30/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Parse/Parse.h>

@interface TAUser : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *bio;
@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic, strong) NSArray *groups;

- (instancetype)initWithStoredUser:(PFUser *)storedUser;
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;
- (PFUser *)getUserAsParseObject;
- (BOOL)isEqualToUser:(TAUser *)user;
- (PFFile *)parseFileForProfileImage;

@end
