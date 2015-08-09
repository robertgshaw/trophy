//
//  TAGroupManager.m
//  Trophy
//
//  Created by Gigster on 1/10/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAGroupManager.h"

#import "TAActiveUserManager.h"
#import "TADefines.h"
#import "TAGroup.h"

#import <Parse/Parse.h>
#import <SVProgressHUD.h>

@implementation TAGroupManager

@synthesize activeGroup = _activeGroup;

+ (instancetype)sharedManager
{
    static TAGroupManager *sharedManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedManager = [[TAGroupManager alloc] init];
    });

    return sharedManager;
}

- (TAGroup *)activeGroup
{
    if (_activeGroup == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedObject = [defaults objectForKey:kCurrentActiveGroup];
        if (encodedObject) {
            _activeGroup = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        }
    }
    return _activeGroup;
}

- (void)setActiveGroup:(TAGroup *)activeGroup
{
    if (activeGroup) {
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:activeGroup];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:encodedObject forKey:kCurrentActiveGroup];
        [defaults synchronize];
    }
    _activeGroup = activeGroup;
}

// loads active group into data by finding TAGroups inside of user and doing a parse query
- (void)loadActiveGroup
{
    NSArray *userGroups = [TAActiveUserManager sharedManager].activeUser.groups;
    if ([userGroups count] > 0)
    {
        // checks to make sure userGroup is correct type, allows typecast below
        if ([userGroups[0] isKindOfClass:[TAGroup class]])
        {
            PFQuery *query = [PFQuery queryWithClassName:@"Group"];
            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
            [query whereKey:@"name" equalTo:((TAGroup *)userGroups[0]).name];
            NSArray *parseGroups = [query findObjects];
            TAGroup *group = [[TAGroup alloc] initWithStoredGroup:parseGroups[0]];
            self.activeGroup = group;
            NSLog(@"active group in load active group %@", self.activeGroup);
        }
    }
    else {
        NSLog(@"No Groups Could Be Found");
    }
}

#pragma mark - Group Management Methods

- (void)createGroup:(TAGroup *)group
            success:(void (^)(TAGroup *group))success
            failure:(void (^)(NSString *error))failure
{
    if ([group.name isEqualToString:@"TestGroup"]) {
        failure(@"Sorry, you can't create a group with the name 'TestGroup'");
    }
    
    PFUser *currentUser = [[TAActiveUserManager sharedManager].activeUser getUserAsParseObject];
    
    PFObject *parseGroup = [[PFObject alloc] initWithClassName:@"Group"];
    parseGroup[@"name"] = group.name;
    parseGroup[@"inviteCode"] = group.inviteCode;
    parseGroup[@"users"] = @[currentUser];
    [parseGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error == nil) {
            if (succeeded) {
                TAGroup *updatedGroup = [[TAGroup alloc] initWithStoredGroup:parseGroup];
                success(updatedGroup);
                
                // Create LeaderboardScore object for user
                PFObject *leaderboardScore = [[PFObject alloc] initWithClassName:@"LeaderboardScore"];
                leaderboardScore[@"groupId"] = parseGroup.objectId;
                leaderboardScore[@"user"] = currentUser;
                leaderboardScore[@"trophyCount"] = @0;
                [leaderboardScore saveInBackground];
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:parseGroup.objectId forKey:@"channels"];
                [currentInstallation saveInBackground];
                NSLog(@"Add user to newly created %@ channel for Group [%@]", parseGroup.objectId, group.name);
            } else {
                failure([error userInfo][@"error"]);
            }
        } else {
            failure(error.description);
        }
    }];
}

// adds user to group via invite code only
- (void)addUserToGroupWithInviteCode:(NSString *)inviteCode
                       success:(void (^)(TAGroup *group))success
                       failure:(void (^)(NSString *error))failure
{
    BlockWeakSelf weakSelf = self;
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKey:@"inviteCode" equalTo:inviteCode];
    [query includeKey:@"users"];
    NSArray *objects = [query findObjects];
    NSLog(@"%@", objects);
    if(objects != nil) {
        if ([objects count] > 0) {
            PFObject *parseGroup = objects[0];
            if ([weakSelf currentUserHasAlreadyJoined:parseGroup] == NO) {
            
                // adds new group to user's group array
                TAUser *currentUser = [TAActiveUserManager sharedManager].activeUser;
                NSArray *groups = currentUser.groups;
                NSMutableArray *newGroups;
                if (groups == nil) {
                    newGroups = [NSMutableArray array];
                } else {
                    newGroups = [currentUser.groups mutableCopy];
                }
                TAGroup *newGroup = [[TAGroup alloc] initWithStoredGroup:parseGroup];
                [newGroups addObject:newGroup];
                
                // updates user on parse
                [[TAActiveUserManager sharedManager] updateUserWithParameters:@{@"groups": newGroups}];
                
                // upates group on parse
                [parseGroup addObject:[[TAActiveUserManager sharedManager].activeUser getUserAsParseObject] forKey:@"users"];
                [parseGroup save];
                
                // adds leaderboard score
                PFObject *leaderboardScore = [[PFObject alloc] initWithClassName:@"LeaderboardScore"];
                leaderboardScore[@"groupId"] = parseGroup.objectId;
                leaderboardScore[@"user"] = [PFUser currentUser];
                leaderboardScore[@"trophyCount"] = @0;
                [leaderboardScore saveInBackground];
                
                // adds current installation
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation addUniqueObject:parseGroup.objectId forKey:@"channels"];
                [currentInstallation saveInBackground];
                NSLog(@"Add user to %@ channel for Group [%@]", parseGroup.objectId, parseGroup[@"name"]);
                
                // sets joined group as active
                [self setActiveGroup:newGroup];
                
                success(newGroup);
            } else {
                failure(@"You are already in that group!");
            }
        } else {
            failure(@"No group could be found");
        }
    } else {
        failure(@"Could Not Add User To Group");
    }
}

- (void)getUsersForActiveGroupWithSuccess:(void (^)(NSArray *users))success
                                  failure:(void (^)(NSString *error))failure
{
    if (self.activeGroup == nil) {
        failure(@"No active group");
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query includeKey:@"users"];
    if ([query hasCachedResult]) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    } else {
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    }
    
    [query getObjectInBackgroundWithId:self.activeGroup.groupId block:^(PFObject *object, NSError *error) {
        if (error == nil) {
            NSLog(@"hi");
            success(object[@"users"]);
        } else {
            failure(error.description);
        }
    }];
}

- (BOOL)currentUserHasAlreadyJoined:(PFObject *)groupObject
{
    NSArray *userGroups = [TAActiveUserManager sharedManager].activeUser.groups;
    for (TAGroup *group in userGroups) {
        if ([[group getGroupAsParseObject].objectId isEqualToString:groupObject.objectId]) {
            return YES;
        }
    }
    return NO;
}

- (void)addActiveUserToTestGroup
{
    TAUser *currentUser = [TAActiveUserManager sharedManager].activeUser;
    PFUser *parseUser = [currentUser getUserAsParseObject];
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKey:@"name" equalTo:@"TestGroup"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error == nil) {
            PFObject *group = object;
            NSArray *users = group[@"users"];
            if (users == nil || [users count] == 0) {
                group[@"users"] = @[parseUser];
                [group saveInBackground];
            } else {
                for (PFUser *member in users) {
                    if ([member.objectId isEqualToString:parseUser.objectId] == NO) {
                        NSMutableArray *updatedUsers = [users mutableCopy];
                        [updatedUsers addObject:parseUser];
                        group[@"users"] = [updatedUsers copy];
                        NSLog(@"Adding user to TestGroup list of users");
                        [group saveInBackground];
                        break;
                    }
                }
            }
            // Add group to user's list of groups
            [[TAActiveUserManager sharedManager] updateUserWithParameters:@{@"groups": @[group]}];
            self.activeGroup = [[TAGroup alloc] initWithStoredGroup:group];
            NSLog(@"Set active group to Test Group");
            
            // Create LeaderboardScore object for user
            PFObject *leaderboardScore = [[PFObject alloc] initWithClassName:@"LeaderboardScore"];
            leaderboardScore[@"groupId"] = group.objectId;
            leaderboardScore[@"user"] = parseUser;
            leaderboardScore[@"trophyCount"] = @0;
            [leaderboardScore saveInBackground];
            NSLog(@"Creating leaderboard score for active user");
            
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation addUniqueObject:group.objectId forKey:@"channels"];
            [currentInstallation saveInBackground];
            NSLog(@"Add user to TestGroup channel");
        } else {
            NSLog(@"%@", error.description);
        }
    }];
}

#pragma mark - Testing/Admin

- (void)createTestGroup
{
    PFObject *testGroup = [[PFObject alloc] initWithClassName:@"Group"];
    testGroup[@"name"] = @"TestGroup";
    testGroup[@"inviteCode"] = @"AAAAAA";
    testGroup[@"users"] = @[];
    [testGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"TestGroup: %@", testGroup.objectId);
        }
    }];
}

- (void)getUsersForTestGroupWithSuccess:(void (^)(NSArray *users))success
                                failure:(void (^)(NSString *error))failure;
{
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query includeKey:@"users"];
    [query whereKey:@"name" equalTo:@"TestGroup"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error == nil) {
            success(object[@"users"]);
        } else {
            failure(error.description);
        }
    }];
}

- (void)addUserToTestGroup:(TAUser *)user
{
    PFUser *parseUser = [user getUserAsParseObject];
    [self addUserIdToTestGroup:parseUser.objectId];
}

- (void)addUserIdToTestGroup:(NSString *)userId
{
    PFQuery *userQuery = [PFUser query];
    [userQuery getObjectInBackgroundWithId:userId block:^(PFObject *object, NSError *error) {
        if (error == nil) {
            PFUser *user = (PFUser *)object;
            PFQuery *query = [PFQuery queryWithClassName:@"Group"];
            [query whereKey:@"name" equalTo:@"TestGroup"];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if (error == nil) {
                    user[@"groups"] = @[object];
                    [user saveInBackground];
                } else {
                    assert(error == nil);
                }
            }];
        } else {
            assert(error == nil);
        }
    }];
}

- (void)addUserToTestGroup:(NSString *)userId withScore:(NSInteger)score
{
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:userId block:^(PFObject *object, NSError *error) {
        PFUser *parseUser = (PFUser *)object;
        PFQuery *query = [PFQuery queryWithClassName:@"Group"];
        [query whereKey:@"name" equalTo:@"TestGroup"];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (error == nil) {
                PFObject *group = object;
                NSArray *users = group[@"users"];
                if (users == nil || [users count] == 0) {
                    group[@"users"] = @[parseUser];
                    [group saveInBackground];
                }
                for (PFUser *member in users) {
                    if ([member.objectId isEqualToString:parseUser.objectId] == NO) {
                        NSMutableArray *updatedUsers = [users mutableCopy];
                        [updatedUsers addObject:parseUser];
                        group[@"users"] = [updatedUsers copy];
                        [group saveInBackground];
                        break;
                    }
                }
                // Add group to user's list of groups
                [[TAActiveUserManager sharedManager] updateUserWithParameters:@{@"groups": @[group]}];
                
                // Create LeaderboardScore object for user
                PFObject *leaderboardScore = [[PFObject alloc] initWithClassName:@"LeaderboardScore"];
                leaderboardScore[@"groupId"] = group.objectId;
                leaderboardScore[@"user"] = parseUser;
                leaderboardScore[@"trophyCount"] = [NSNumber numberWithInteger:score];
                [leaderboardScore saveInBackground];
            } else {
                NSLog(@"%@", error.description);
            }
        }];
    }];
}

@end
