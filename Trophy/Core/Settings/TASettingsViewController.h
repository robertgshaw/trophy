//
//  TAProfileViewController.h
//  Trophy
//
//  Created by Gigster on 12/20/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TARootViewController.h"

@protocol TASettingsViewControllerDelegate <NSObject>
@required
- (void)settingsViewControllerDidUpdateProfileSettings;
@end

@interface TASettingsViewController : UIViewController

@property (nonatomic, weak) id<TASettingsViewControllerDelegate> delegate;

- (instancetype)initWithSetupFlow:(BOOL)shouldShowSetupFlow;

@end
