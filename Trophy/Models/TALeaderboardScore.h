//
//  TALeaderboardScore.h
//  Trophy
//
//  Created by Gigster on 1/19/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#import "TAUser.h"


@interface TALeaderboardScore : NSObject

- (instancetype)initWithStoredLeaderboardScore:(PFObject *)score includeUser:(BOOL)includeUser;

@property (nonatomic, strong) TAUser *user;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, assign) NSInteger trophyCount;

@end
