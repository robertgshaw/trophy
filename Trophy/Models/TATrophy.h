//
//  TATrophy.h
//  TATrophy
//
//  Created by Gigster on 12/29/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

#import "TAUser.h"

@interface TATrophy : NSObject

@property (nonatomic, strong) TAUser *recipient;
@property (nonatomic, strong) TAUser *author;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, assign) NSInteger likes;
@property (nonatomic, strong) NSArray *likedUserIds;
@property (nonatomic, assign) NSArray *comments;
@property (nonatomic, assign) NSInteger commentNumber;

- (instancetype)initWithStoredTrophy:(PFObject *)storedTrophy;
- (BOOL)likedByCurrentUser;
- (PFObject *)getTrophyAsParseObject;
- (PFFile *)parseFileForTrophyImage;

@end
