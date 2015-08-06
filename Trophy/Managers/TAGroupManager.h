//
//  TAGroupManager.h
//  Trophy
//
//  Created by Gigster on 1/10/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TAGroup.h"
#import "TATrophy.h"
#import "TAUser.h"

@interface TAGroupManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong) TAGroup *activeGroup;

- (void)loadActiveGroup;

- (void)createGroup:(TAGroup *)group
            success:(void (^)(TAGroup *group))success
            failure:(void (^)(NSString *error))failure;

//- (void)addUserToGroupWithName:(NSString *)groupName
//                    inviteCode:(NSString *)inviteCode
//                       success:(void (^)(TAGroup *group))success
//                       failure:(void (^)(NSString *error))failure;
- (void)addUserToGroupWithInviteCode:(NSString *)inviteCode
                       success:(void (^)(TAGroup *group))success
                       failure:(void (^)(NSString *error))failure;

- (void)getUsersForActiveGroupWithSuccess:(void (^)(NSArray *users))success
                                  failure:(void (^)(NSString *error))failure;

- (void)addActiveUserToTestGroup;

#pragma mark - Testing/Admin

- (void)createTestGroup;

//- (void)getUsersForTestGroupWithSuccess:(void (^)(NSArray *users))success
//                                failure:(void (^)(NSString *error))failure;

//- (void)addUserToTestGroup:(NSString *)userId withScore:(NSInteger)score;

//- (void)addUserToTestGroup:(TAUser *)user;

//- (void)addUserIdToTestGroup:(NSString *)userId;

@end
