//
//  TACommentActivityTableViewCell.h
//  Trophy
//
//  Created by Kenny Okagaki on 6/25/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TACommentBaseTableViewCell.h"

@protocol TACommentActivityTableViewCellDelegate;

@interface TACommentActivityTableViewCell : TACommentBaseTableViewCell

/*! Setter for the activity associated with this cell */
@property (nonatomic, strong) PFObject *activity;

/*! Set the new state. This changes the background of the cell. */
- (void)setIsNew:(BOOL)isNew;

@end


/*!
 The protocol defines methods a delegate of a PAPBaseTextCell should implement.
 */
@protocol TACommentActivityTableViewCellDelegate <TACommentBaseTableViewCellDelegate>
@optional

/*!
 Sent to the delegate when the activity button is tapped
 @param activity the PFObject of the activity that was tapped
 */
- (void)cell:(TACommentActivityTableViewCell *)cellView didTapActivityButton:(PFObject *)activity;

@end
