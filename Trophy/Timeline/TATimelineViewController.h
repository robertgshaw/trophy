//
//  TATimelineViewController.h
//  Trophy
//
//  Created by Gigster on 12/22/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import <ParseUI/ParseUI.h>
#import <UIKit/UIKit.h>
#import "TAMainViewController.h"

@interface TATimelineViewController : PFQueryTableViewController

@property (nonatomic, weak) id<TAPresentedViewControllerDelegate>presentedDelegate;

@end
