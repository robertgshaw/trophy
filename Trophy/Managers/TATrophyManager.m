//
//  TATrophyManager.m
//  Trophy
//
//  Created by Gigster on 1/18/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TATrophyManager.h"

#import "TAActiveUserManager.h"
#import "TADefines.h"
#import "TAGroupManager.h"

#import <SVProgressHUD.h>

@implementation TATrophyManager

+ (instancetype)sharedManager
{
    static TATrophyManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [[TATrophyManager alloc] init];
    });
    
    return sharedManager;
}

- (void)addTrophyToActiveGroup:(TATrophy *)trophy
                     success:(void (^)(void))success
                     failure:(void (^)(NSString *error))failure
{
    NSString *groupId = [TAGroupManager sharedManager].activeGroup.groupId;
    
    void (^uploadTrophy)(PFFile *imageFile) = ^(PFFile *imageFile){
        PFObject *trophyObject = [[PFObject alloc] initWithClassName:@"Trophy"];
        trophyObject[@"recipient"] = [trophy.recipient getUserAsParseObject];
        trophyObject[@"author"] = [trophy.author getUserAsParseObject];
        trophyObject[@"caption"] = trophy.caption;
        trophyObject[@"imageFile"] = imageFile;
        trophyObject[@"time"] = trophy.time;
        trophyObject[@"groupId"] = groupId;
        trophyObject[@"likes"] = [NSNumber numberWithInteger:trophy.likes];
        trophyObject[@"comments"] = [NSNull null];
        
        [trophyObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error == nil) {
                [self getLeaderboardScoreObjectForUser:trophy.recipient
                                           withGroupId:groupId
                                               success:^(PFObject *object) {
                                                   [SVProgressHUD dismiss];
                                                   [object incrementKey:@"trophyCount"];
                                                   [object saveEventually];
                                                   success();
                                               } failure:^(NSString *error) {
                                                   [SVProgressHUD dismiss];
                                                   failure(error.description);
                                               }];
                [self sendPushNotifications:trophy];
            } else {
                [SVProgressHUD dismiss];
                failure(error.description);
            }
        }];
    };
    
    NSData *imageData = UIImageJPEGRepresentation(trophy.image, .25f);
    [self uploadImage:imageData withCompletion:uploadTrophy];
}

- (TATrophy *)likeTrophy:(TATrophy *)trophy
{
    TAUser *currentUser = [TAActiveUserManager sharedManager].activeUser;
    PFObject *userObject = [currentUser getUserAsParseObject];
    PFObject *trophyObject = [trophy getTrophyAsParseObject];
    
    if ([trophy likedByCurrentUser]) {
        // If user has already liked Trophy, unlike it
        NSMutableArray *updatedLikedUserIds = [trophy.likedUserIds mutableCopy];
        [updatedLikedUserIds removeObject:userObject.objectId];
        trophyObject[@"likedUserIds"] = updatedLikedUserIds;
        [trophyObject incrementKey:@"likes" byAmount:[NSNumber numberWithInt:(-1)]];
        [trophyObject saveEventually];
    } else {
        // If a user has not liked the Trophy, like it
        NSMutableArray *updatedLikedUserIds = [trophy.likedUserIds mutableCopy];
        if (updatedLikedUserIds == nil) {
            updatedLikedUserIds = [NSMutableArray array];
        }
        [updatedLikedUserIds addObject:userObject.objectId];
        trophyObject[@"likedUserIds"] = updatedLikedUserIds;
        [trophyObject incrementKey:@"likes"];
        [trophyObject saveEventually];
    }
    return [[TATrophy alloc] initWithStoredTrophy:trophyObject];
}

- (void)sendPushNotifications:(TATrophy *)trophy
{
    NSString *currentGroup = [TAGroupManager sharedManager].activeGroup.groupId;
    NSString *message = [NSString stringWithFormat:@"%@ just added a new Trophy!", trophy.author.name];
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:currentGroup];
    [push setMessage:message];
    [push sendPushInBackground];
}

- (void)uploadImage:(NSData *)imageData withCompletion:(void (^)(PFFile *imageFile))completion
{
    [SVProgressHUD showWithStatus:@"Uploading Trophy" maskType:SVProgressHUDMaskTypeBlack];
    PFFile *imageFile = [PFFile fileWithName:@"image.jpg" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error == nil && succeeded) {
            completion(imageFile);
        } else {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:error.description maskType:SVProgressHUDMaskTypeBlack];
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        NSLog(@"Updating (%d%% done)", percentDone);
    }];
}

- (void)getTrophiesForUser:(TAUser *)user
                   success:(void (^)(NSArray *trophies))success
                   failure:(void (^)(NSString *error))failure
{
    TAGroup *currentGroup = [TAGroupManager sharedManager].activeGroup;
    PFUser *parseUser = [user getUserAsParseObject];
    PFQuery *query = [PFQuery queryWithClassName:@"Trophy"];
    [query whereKey:@"recipient" equalTo:parseUser];
    [query includeKey:@"recipient"];
    [query includeKey:@"author"];
    [query whereKey:@"groupId" equalTo:currentGroup.groupId];
    if ([query hasCachedResult]) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    } else {
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            success(objects);
        } else {
            failure(error.description);
        }
    }];
}

- (void)refreshUser:(TAUser *)user
            success:(void (^)(TAUser *user))success
            failure:(void (^)(NSString *error))failure
{
    if (user == nil) return;
    
    PFUser *currentUser = [user getUserAsParseObject];
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:currentUser.objectId];
    if ([query hasCachedResult]) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    } else {
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    }
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error == nil) {
            success([[TAUser alloc] initWithStoredUser:(PFUser *)object]);
        } else {
            failure(error.description);
        }
    }];
}

- (void)getLeaderboardScoreObjectForUser:(TAUser *)user
                             withGroupId:(NSString *)groupId
                                 success:(void (^)(PFObject *object))success
                                 failure:(void (^)(NSString *error))failure
{
    if (user == nil) return;
    
    PFUser *parseUser = [user getUserAsParseObject];
    PFQuery *innerQuery = [PFUser query];
    [innerQuery whereKey:@"objectId" equalTo:parseUser.objectId];
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"LeaderboardScore"];
    [query whereKey:@"groupId" equalTo:groupId];
    [query whereKey:@"user" matchesQuery:innerQuery];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error == nil) {
            success(object);
        } else {
            failure(error.description);
        }
    }];
}

- (void)getLeaderboardScoreForUser:(TAUser *)user
                           inGroup:(TAGroup *)group
                           success:(void (^)(TALeaderboardScore *score))success
                           failure:(void (^)(NSString *error))failure
{
    if (user == nil) return;
    NSString *groupId = [TAGroupManager sharedManager].activeGroup.groupId;
    
    PFUser *parseUser = [user getUserAsParseObject];
    PFQuery *innerQuery = [PFUser query];
    [innerQuery whereKey:@"objectId" equalTo:parseUser.objectId];
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"LeaderboardScore"];
    [query whereKey:@"groupId" equalTo:groupId];
    [query whereKey:@"user" matchesQuery:innerQuery];
    if ([query hasCachedResult]) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    } else {
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    }
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error == nil) {
            TALeaderboardScore *score = [[TALeaderboardScore alloc] initWithStoredLeaderboardScore:object includeUser:NO];
            success(score);
        } else {
            failure(error.description);
        }
    }];
}

@end
