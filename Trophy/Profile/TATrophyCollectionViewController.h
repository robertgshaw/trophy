//
//  TATrophyCollectionViewController.h
//  Trophy
//
//  Created by Gigster on 1/18/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAProfileViewController.h"

@interface TATrophyCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSArray *trophies;
@property (nonatomic, strong) TAProfileViewController *delegate;

@end
