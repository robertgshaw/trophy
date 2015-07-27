//
//  TATrophyManager.h
//  Trophy
//
//  Created by Gigster on 1/18/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TAGroup.h"
#import "TALeaderboardScore.h"
#import "TATrophy.h"
#import "TAUser.h"

@interface TATrophyManager : NSObject

+ (instancetype)sharedManager;

- (void)addTrophyToActiveGroup:(TATrophy *)trophy
                       success:(void (^)(void))success
                       failure:(void (^)(NSString *error))failure;

- (TATrophy *)likeTrophy:(TATrophy *)trophy;

- (void)getTrophiesForUser:(TAUser *)user
                   success:(void (^)(NSArray *trophies))success
                   failure:(void (^)(NSString *error))failure;

- (void)refreshUser:(TAUser *)user
            success:(void (^)(TAUser *user))success
            failure:(void (^)(NSString *error))failure;

- (void)getLeaderboardScoreForUser:(TAUser *)user
                           inGroup:(TAGroup *)group
                           success:(void (^)(TALeaderboardScore *score))success
                           failure:(void (^)(NSString *error))failure;

@end
