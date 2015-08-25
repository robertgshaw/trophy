//
//  TABackButton.m
//  Trophy
//
//  Created by Robert Shaw on 8/11/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TABackButton.h"
#import "UIColor+TAAdditions.h"

@implementation TABackButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addTarget:self action:@selector(didPressBackButton) forControlEvents:UIControlEventTouchUpInside];
        
        [self setBackgroundImage:[UIImage imageNamed:@"closeup-close-icon"] forState:UIControlStateNormal];
    }
    
    return self;
}

#pragma mark - back button pressed handler
- (void)didPressBackButton
{
    [self.delegate backButtonDidPressBack];
}

@end
