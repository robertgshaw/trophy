//
//  TABackButton.m
//  Trophy
//
//  Created by Robert Shaw on 8/11/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TABackButton.h"
#import "UIColor+TAAdditions.h"

@interface TABackButton ()

@property (nonatomic, strong) UILabel *backLabel;
@property (nonatomic, strong) UIImageView *backLogo;

@end

@implementation TABackButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addTarget:self action:@selector(didPressBackButton) forControlEvents:UIControlEventTouchUpInside];
        
        // initializes back label
        self.backLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.backLabel.text = @"Back";
        self.backLabel.textColor = [UIColor trophyYellowColor];
        [self addSubview:self.backLabel];
        
        // initializes back logo
        self.backLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left-arrow"]];
        [self addSubview:self.backLogo];
    
    }
    
    return self;
}

- (void) layoutSubviews
{
    // lays out the back logo
    CGRect frame = self.backLogo.frame;
    frame.size = CGSizeMake(20.0, 20.0);
    frame.origin.x = 0.0;
    frame.origin.y = 0.0;
    self.backLogo.frame = frame;
    
    // lays out the back label
    [self.backLabel sizeToFit];
    frame = self.backLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.backLogo.frame);
    frame.origin.y = self.backLogo.frame.origin.y;
    self.backLabel.frame = frame;

}
#pragma mark - back button pressed handler
- (void)didPressBackButton
{
    [self.delegate backButtonDidPressBack];
}

@end
