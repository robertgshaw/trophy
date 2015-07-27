//
//  TALoginViewController.h
//  Trophy
//
//  Created by Gigster on 1/2/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TALoginViewControllerDelegate <NSObject>
@required
- (void)loginViewControllerDidLoginWithSuccess;
@end

@interface TALoginViewController : UIViewController

@property (nonatomic, weak) id<TALoginViewControllerDelegate> delegate;

@end
