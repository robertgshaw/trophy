//
//  TALeaderboardScore.m
//  Trophy
//
//  Created by Gigster on 1/19/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TALeaderboardScore.h"

@interface TALeaderboardScore ()

@property (nonatomic, strong) PFObject *parseScore;

@end

@implementation TALeaderboardScore

- (instancetype)initWithStoredLeaderboardScore:(PFObject *)score includeUser:(BOOL)includeUser
{
    self = [super init];
    if (self) {
        _parseScore = score;
        if (includeUser) {
            self.user = [[TAUser alloc] initWithStoredUser:score[@"user"]];
        }
        self.groupId = score[@"groupId"];
        self.trophyCount = [score[@"trophyCount"] integerValue];
    }
    return self;
}

@end
