//
//  TADefines.h
//  Trophy
//
//  Created by Gigster on 1/10/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface TADefines : NSObject

#define BlockWeakObject(o) __typeof(o) __weak
#define BlockWeakSelf BlockWeakObject(self)

extern NSString * const kCurrentActiveGroup;
extern NSString * const kCurrentActiveUser;

@end
