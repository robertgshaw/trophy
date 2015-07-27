//
//  TAAddGroupViewController.h
//  Trophy
//
//  Created by Gigster on 1/30/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TACreateGroupViewController.h"
#import "TAJoinGroupViewController.h"

@interface TAAddGroupViewController : UIViewController

@property (nonatomic, weak) id<TACreateGroupViewControllerDelegate, TAJoinGroupViewControllerDelegate> delegate;

@end
