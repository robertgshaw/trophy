//
//  TAActiveUserManager.m
//  Trophy
//
//  Created by Gigster on 12/30/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import "TAActiveUserManager.h"

#import "TADefines.h"
#import "TAMainViewController.h"
#import "TASignupViewController.h"
#import "TATimelineViewController.h"
#import "TAGroupManager.h"
#import "TAOnboardingViewController.h"

#import <Parse/Parse.h>

#define CREATE_TEST_GROUP NO


@implementation TAActiveUserManager

@synthesize activeUser = _activeUser;

+ (instancetype)sharedManager
{
    static TAActiveUserManager *sharedManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedManager = [[TAActiveUserManager alloc] init];
    });

    return sharedManager;
}

- (TAUser *)activeUser
{
    if (_activeUser == nil && [self hasCurrentUser]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedObject = [defaults objectForKey:kCurrentActiveUser];
        if (encodedObject) {
            _activeUser = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        }
        if (_activeUser == nil) {
            _activeUser = [[TAUser alloc] initWithStoredUser:[PFUser currentUser]];
        }
    }
    return _activeUser;
}

- (void)setActiveUser:(TAUser *)activeUser
{
    _activeUser = activeUser;
    if (activeUser) {
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:activeUser];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:encodedObject forKey:kCurrentActiveUser];
        [defaults synchronize];
    }
}

- (BOOL)hasCurrentUser
{
    return [PFUser currentUser];
}

#pragma mark - Startup Methods

- (void)startOrResumeAppSession
{
    if (CREATE_TEST_GROUP) {
        [[TAGroupManager sharedManager] createTestGroup];
    } else {
        if (self.hasCurrentUser) {
            [self configureActiveUser];
            
            // if no groups, go to onboarding view controller
            if ([self.activeUser.groups count] == 0)
            {
                [self transitionToOnboardingViewController];
            
            // otherwise go to main view
            } else {
                [self transitionToMainViewController];
            }
        } else {
            [self transitionToAccountSetupFlow];
        }
    }
}

- (void)configureActiveUser
{
    if (self.hasCurrentUser) {
        // refreshes user information and saves all info in TAActiveUserManager.TAUser
        [self refreshActiveUserWithSuccess:nil failure: ^(NSString *error) {
                                                    NSLog(@"%@", error); }];
        
        // loads active group into data via a parse call
        [[TAGroupManager sharedManager] loadActiveGroup];
    }
}

- (void)refreshActiveUser
{
    [self refreshActiveUserWithSuccess:nil failure:nil];
}

- (void)refreshActiveUserWithSuccess:(void (^)(void))success
                             failure:(void (^)(NSString *error))failure
{
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:currentUser.objectId];
    [query includeKey:@"groups"];
    PFObject *user = [query getFirstObject];
    if (user == nil) {
        [[TAActiveUserManager sharedManager] endSession];
        failure(@"Could not retrieve User info");
    } else {
        self.activeUser = [[TAUser alloc] initWithStoredUser:(PFUser *)user];
        if (success) {
                success();
        }
    }
}

- (void)checkGroupsForActiveUser
{
    if (self.activeUser.groups == nil) {
        NSLog(@"Something went wrong with the group setup.");
    }
}

#pragma mark - Account Management Methods

- (void)registerWithUser:(TAUser *)user
                 success:(void (^)(void))success
                 failure:(void (^)(NSString *error))failure
{
    PFUser *newUser = [[PFUser alloc] init];
    newUser.username = user.username;
    newUser.password = user.password;
    newUser[@"phone"] = user.phoneNumber;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error == nil && succeeded) {
            self.activeUser = [[TAUser alloc] initWithStoredUser:newUser];
            success();
        } else {
            NSString *errorString = [error userInfo][@"error"];
            failure(errorString);
        }
    }];
}

- (void)loginWithParameters:(NSDictionary *)dictionary
                    success:(void (^)(void))success
                    failure:(void (^)(NSString *error))failure
{
    if ([self hasCurrentUser]) {
        [PFUser logOut];
        [PFQuery clearAllCachedResults];
        self.activeUser = nil;
    }

    // if username exists
    NSString *username = [dictionary objectForKey:@"username"];
    NSString *password = [dictionary objectForKey:@"password"];
    if (username) {
        [PFUser logInWithUsernameInBackground:username password:password
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                [self configureNotificationsSettings];
                                                success();
                                            } else {
                                                NSString *errorString = [error userInfo][@"error"];
                                                failure(errorString);
                                            }
                                        }];
    }
}

- (void)endSession
{
    [PFUser logOut];
    [PFQuery clearAllCachedResults];
    [self removeAllNotificationsSettings];
    self.activeUser = nil;
    [self transitionToAccountSetupFlow];
}

#pragma mark - User Settings Methods

- (void)updateUserWithParameters:(NSDictionary *)dictionary
{
    if ([self hasCurrentUser] == NO || dictionary == nil) return;
    for (NSString *key in dictionary) {
        assert ([self.activeUser respondsToSelector:NSSelectorFromString(key)]);
        [self.activeUser setValue:[dictionary objectForKey:key] forKey:key];
        NSLog(@"Setting key %@ for active user", key);
    }
    PFUser *currentUser = [self.activeUser getUserAsParseObject];
    [currentUser save];
    NSLog(@"Saving user in background");
}

- (void)updateUserWithParameters:(NSDictionary *)dictionary
                         success:(void (^)(void))success
                         failure:(void (^)(NSString *error))failure
{
    if ([self hasCurrentUser] == NO) {
        failure(@"User does not exist!");
    }
    
    for (NSString *key in dictionary) {
        assert ([self.activeUser respondsToSelector:NSSelectorFromString(key)]);
        [self.activeUser setValue:[dictionary objectForKey:key] forKey:key];
    }
    PFUser *currentUser = [self.activeUser getUserAsParseObject];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            success();
        } else {
            NSString *errorString = [error userInfo][@"error"];
            failure(errorString);
        }
    }];
}

#pragma mark - Notifications Handling

- (void)registerForNotifications
{
    PFUser *user = [PFUser currentUser];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:user forKey:@"owner"];
    [currentInstallation saveInBackground];
}

- (void)removeAllNotificationsSettings
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.channels = [NSArray array];
    [currentInstallation removeObjectForKey:@"owner"];
    [currentInstallation save];
}

- (void)configureNotificationsSettings
{
    PFUser *user = [PFUser currentUser];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:user forKey:@"owner"];
    [currentInstallation saveEventually];
    
    // Set up notifications for all the groups
    [self refreshActiveUserWithSuccess:^{
        NSMutableArray *channels = [NSMutableArray array];
        for (id group in self.activeUser.groups) {
            if ([group isKindOfClass:[TAGroup class]]) {
                TAGroup *checkedGroup = (TAGroup *)group;
                [channels addObject:checkedGroup.name];
            } else if ([group isKindOfClass:[PFObject class]]) {
                TAGroup *checkedGroup = [[TAGroup alloc] initWithStoredGroup:group];
                [channels addObject:checkedGroup.name];
            }
        }
        if ([channels count] > 0) {
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            currentInstallation.channels = channels;
            [currentInstallation saveEventually];
        }
    } failure:^(NSString *error) {
        NSLog(@"Error! Could not configure notifications settings");
    }];
}

#pragma mark - Navigation Methods

- (void)signupSuccessfulForActiveUser
{
    //[[TAGroupManager sharedManager] addActiveUserToTestGroup];
    [self registerForNotifications];
}

// on successful signup/ login, send user to correct location
- (void)accountSetupSuccessfulForActiveUser
{
    if ([self.activeUser.groups count] == 0) {
        [self transitionToOnboardingViewController];
    } else {
        [self configureActiveUser];
        [self transitionToMainViewController];
    }
}

// handles successful onboarding by sending to main view controller
- (void) onboardingSuccessfulForActiveUser
{
    // check to make sure user still exists, goes to main view controller
    if (self.hasCurrentUser) {    
        [self configureActiveUser];
        [self transitionToMainViewController];
        
    } else {
        [self transitionToAccountSetupFlow];
    }
}

- (void)transitionToAccountSetupFlow
{
    TASignupViewController *signupViewController = [[TASignupViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:signupViewController];
    [self.delegate transitionToViewController:navController animated:NO withCompletion:nil];
}

- (void)transitionToMainViewController
{
    TAMainViewController *mainViewController = [[TAMainViewController alloc] init];
    [self.delegate transitionToViewController:mainViewController animated:NO withCompletion:nil];
}


- (void) transitionToOnboardingViewController
{
    TAOnboardingViewController *onboardingViewController = [[TAOnboardingViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:onboardingViewController];
    [self.delegate transitionToViewController:navController animated:NO withCompletion:nil];
}

@end
