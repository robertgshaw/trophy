//
//  TAActiveUserManager.h
//  Trophy
//
//  Created by Gigster on 12/30/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TAGroup.h"
#import "TARootViewController.h"
#import "TAUser.h"

@protocol TAActiveUserManagerDelegate
@required
- (void)transitionToAccountSetupLoggedOutFlow:(BOOL)loggedOutFlow;
@end

@interface TAActiveUserManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, weak) id<TAAppSessionManagerDelegate> delegate;
@property (nonatomic, strong) TAUser *activeUser;
@property (nonatomic, assign) BOOL hasCurrentUser;

- (void)configureActiveUser;

- (void)refreshActiveUserWithSuccess:(void (^)(void))success
                             failure:(void (^)(NSString *error))failure;

- (void)registerWithUser:(TAUser *)user
                 success:(void (^)(void))success
                 failure:(void (^)(NSString *error))failure;

- (void)transitionToSignupViewController;

- (void)transitionToLoginViewController;

- (void)signupSuccessfulForActiveUser;

- (void)accountSetupSuccessfulForActiveUser;

- (void)onboardingSuccessfulForActiveUser;

- (void)loginWithParameters:(NSDictionary *)dictionary
                    success:(void (^)(void))success
                    failure:(void (^)(NSString *error))failure;

- (void)updateUserWithParameters:(NSDictionary *)dictionary;

- (void)updateUserWithParameters:(NSDictionary *)dictionary
                         success:(void (^)(void))success
                         failure:(void (^)(NSString *error))failure;

- (void)startOrResumeAppSession;

- (void)endSession;

@end
