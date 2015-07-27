//
//  TACommentTableViewController.h
//  Trophy
//
//  Created by Kenny Okagaki on 6/25/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "TATrophy.h"
#import "TACommentBaseTableViewCell.h"

@protocol TACommentTableViewControllerDelegate;

@interface TACommentTableViewController : PFQueryTableViewController <UITextFieldDelegate, UIActionSheetDelegate, TACommentBaseTableViewCellDelegate>

// below is trying to fit the architecture for calling closeup VC from timeline VC... 7/7
//- (instancetype)initWithTrophy:(TATrophy *)trophy;
@property (nonatomic, weak) id<TACommentTableViewControllerDelegate> delegate;

@property (nonatomic, strong) PFObject *photo;

//- (id)initWithPhoto:(PFObject*)aPhoto;
- (id)initWithPhoto:(TATrophy*)trophy;

@end

