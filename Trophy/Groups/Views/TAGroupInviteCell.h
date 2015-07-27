//
//  TAGroupInviteCell.h
//  Trophy
//
//  Created by Gigster on 1/26/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TAFriendContact.h"

@class TAGroupInviteCell;

@protocol TAGroupInviteCellDelegate <NSObject>

- (void)groupInviteCellDidPressSend:(TAGroupInviteCell *)inviteCell;

@end

@interface TAGroupInviteCell : UITableViewCell

@property (nonatomic, weak) id<TAGroupInviteCellDelegate> delegate;
@property (nonatomic, weak) TAFriendContact *contact;

@end
