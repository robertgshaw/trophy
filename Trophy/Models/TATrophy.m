//
//  TATrophy.m
//  TATrophy
//
//  Created by Gigster on 12/29/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import "TATrophy.h"

#import "TAActiveUserManager.h"

@interface TATrophy ()

@property (nonatomic, strong) PFObject *parseObject;
@property (nonatomic, strong) PFFile *imageFile;

@end

@implementation TATrophy

- (instancetype)initWithStoredTrophy:(PFObject *)storedTrophy
{
    self = [super init];
    if (self) {
        _parseObject = storedTrophy;
        
        self.recipient = [[TAUser alloc] initWithStoredUser:storedTrophy[@"recipient"]];
        self.author = [[TAUser alloc] initWithStoredUser:storedTrophy[@"author"]];
        self.caption = storedTrophy[@"caption"];
        self.imageFile = storedTrophy[@"imageFile"];
        self.time = storedTrophy[@"time"];
        self.groupId = storedTrophy[@"groupId"];
        self.likes = [storedTrophy[@"likes"] integerValue];
        self.likedUserIds = storedTrophy[@"likedUserIds"];
        self.comments = nil;
        self.commentCount = [self updateCommentCount];

        [self.imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                _image = [UIImage imageWithData:data];
            }
        }];
    }
    return self;
}

- (BOOL)likedByCurrentUser
{
    TAUser *currentUser = [TAActiveUserManager sharedManager].activeUser;
    PFUser *userObject = [currentUser getUserAsParseObject];
    if ([self.likedUserIds containsObject:userObject.objectId]) {
        return YES;
    }
    return NO;
}

// function to populate the comments array
- (NSInteger)updateCommentCount
{
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    
    [query whereKey:@"trophy" equalTo:self.parseObject];
    [query whereKey:@"type" equalTo:@"comment"];
    
    return query.countObjects;
}

- (PFObject *)getTrophyAsParseObject
{
    return self.parseObject;
}

- (PFFile *)parseFileForTrophyImage
{
    return self.imageFile;
}

@end
