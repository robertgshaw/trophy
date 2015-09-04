//
//  TASplashPageView.m
//  Trophy
//
//  Created by Matt Deveney on 9/4/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TASplashPageView.h"
#import "UIColor+TAAdditions.h"


@interface TASplashPageView ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UIButton *getStartedButton;

@end

@implementation TASplashPageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // configures logo
        self.logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-large"]];
        [self addSubview:self.logoImageView];
        
        // configueres caption
        self.captionLabel = [[UILabel alloc] init];
        self.captionLabel.text = @"Trophy provides groups with a better way to share photos privately.";
        self.captionLabel.textColor = [UIColor whiteColor];
        self.captionLabel.font = [UIFont fontWithName:@"Avenir" size:22.0];
        self.captionLabel.numberOfLines = 4;
        self.captionLabel.textAlignment = NSTextAlignmentCenter;
        self.captionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.captionLabel];
        
        // configures button
        self.getStartedButton = [[UIButton alloc] init];
        [self.getStartedButton setTitle:@"Let's get started" forState:UIControlStateNormal];
        [self.getStartedButton setTitleColor:[UIColor trophyNavyColor] forState:UIControlStateNormal];
        self.getStartedButton.backgroundColor = [UIColor trophyYellowColor];
        self.getStartedButton.layer.cornerRadius = 5.0;
        self.getStartedButton.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:17.0];
        [self.getStartedButton addTarget:self action:@selector(getStartedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.getStartedButton];
    }
    
    // configure logo image
    return self;
}

-(void) layoutSubviews {
    
    // layout logo
    CGRect frame = self.logoImageView.frame;
    frame.size.width = self.bounds.size.width * 0.5;
    frame.size.height = frame.size.width;
    frame.origin.x = CGRectGetMidX(self.bounds) - frame.size.width / 2;
    frame.origin.y = CGRectGetMidY(self.bounds) - frame.size.height * 1.3;
    self.logoImageView.frame = frame;
    
    // layout caption label
    frame= self.captionLabel.frame;
    frame.size.width = self.bounds.size.width * 0.75;
    frame.size.height = self.frame.size.height * 0.2;
    frame.origin.x = CGRectGetMidX(self.bounds) - frame.size.width / 2;
    frame.origin.y = CGRectGetMaxY(self.logoImageView.frame) + (self.bounds.size.height * .05);
    self.captionLabel.frame = frame;
    
    // layout get started button
    frame = self.getStartedButton.frame;
    frame.size.width = self.bounds.size.width * 0.6;
    frame.size.height = self.bounds.size.height * .08;
    frame.origin.x = CGRectGetMidX(self.bounds) - frame.size.width / 2;
    frame.origin.y = frame.origin.y = CGRectGetMaxY(self.captionLabel.frame) + (self.bounds.size.height * .05);
    self.getStartedButton.frame = frame;
    
}


-(void)getStartedButtonPressed:(id) sender
{
    [self.delegate splashPageViewDidPressGetStarted:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

