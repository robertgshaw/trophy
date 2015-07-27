//
//  TALeaderboardTableViewCell.h
//  Trophy
//
//  Created by Gigster on 2/15/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <ParseUI/ParseUI.h>

#import "TALeaderboardScore.h"

@interface TALeaderboardTableViewCell : PFTableViewCell

@property (nonatomic, strong) TALeaderboardScore *score;

- (void)setRank:(NSInteger)rank;
- (CGFloat)heightForCell;

@end
