//
//  TATrophyCollectionViewCell.m
//  Trophy
//
//  Created by Gigster on 1/18/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TATrophyCollectionViewCell.h"

#import <ParseUI/ParseUI.h>

static const CGFloat kTrophyImageTopMargin = 20.0;
static const CGFloat kTrophyImageWidth = 200.0;
static const CGFloat kTrophyImageHeight = 300.0;
static const CGFloat kTrophyBottomMargin = 50.0;

@interface TATrophyCollectionViewCell ()

@property (nonatomic, strong) UIImageView *trophyIconView;
@property (nonatomic, strong) PFImageView *trophyImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) TATrophyActionFooterView *actionFooterView;

@end

@implementation TATrophyCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _trophyImageView = [[PFImageView alloc] init];
        self.trophyImageView.layer.cornerRadius = 5.0;
        self.trophyImageView.layer.masksToBounds = YES;
        [self addSubview:self.trophyImageView];
        
      //  _trophyIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trophy-collection-icon"]];
        //[self addSubview:self.trophyIconView];
        
        _titleLabel = [[UILabel alloc] init];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:11.0];
        [self addSubview:self.titleLabel];
        
         _dateLabel = [[UILabel alloc] init];
        [self.dateLabel setTextAlignment:NSTextAlignmentCenter];
        self.dateLabel.textColor = [UIColor colorWithRed:0.98 green:0.808 blue:0.184 alpha:1];
        self.dateLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:self.dateLabel];
        
        _authorLabel = [[UILabel alloc] init];
        [self.authorLabel setTextAlignment:NSTextAlignmentCenter];
        self.authorLabel.textColor = [UIColor blackColor];
        self.authorLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:self.authorLabel];
        
        _actionFooterView = [[TATrophyActionFooterView alloc] initWithFrame:CGRectZero];
        self.actionFooterView.delegate = self.actionFooterDelegate;
        [self addSubview:self.actionFooterView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.trophyIconView.frame;
    frame.origin.x = CGRectGetMidX(self.bounds) - floorf(CGRectGetWidth(self.trophyIconView.frame) / 2.0);
    frame.origin.y = kTrophyImageTopMargin;
    self.trophyIconView.frame = frame;
    
    frame = self.trophyImageView.frame;
    frame.size = CGSizeMake(kTrophyImageWidth, kTrophyImageHeight);
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - kTrophyImageWidth) / 2.0);
    frame.origin.y = CGRectGetMidY(self.trophyIconView.frame) - floorf(kTrophyImageWidth / 2.0) +119;
    self.trophyImageView.frame = frame;
    
    frame = self.actionFooterView.frame;
    frame.size = CGSizeMake([TATrophyActionFooterView actionFooterWidth], 20.0);
    frame.origin.x = CGRectGetMidX(self.bounds) - floorf([TATrophyActionFooterView actionFooterWidth] / 2.0)+60;
    frame.origin.y = CGRectGetMaxY(self.bounds) - kTrophyBottomMargin - 20;
    self.actionFooterView.frame = frame;
    
    [self.authorLabel sizeToFit];
    frame = self.authorLabel.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.authorLabel.frame)) / 2.0);
    frame.origin.y =  CGRectGetMidY(self.trophyIconView.frame) - floorf(kTrophyImageWidth / 2.0) +95;
    self.authorLabel.frame = frame;
    
    [self.dateLabel sizeToFit];
    frame = self.dateLabel.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.dateLabel.frame)) / 2.0);
    frame.origin.y = CGRectGetMinY(self.authorLabel.frame) - CGRectGetHeight(self.dateLabel.frame) - 10.0;
    self.dateLabel.frame = frame;
    
    [self.titleLabel sizeToFit];
    frame = self.titleLabel.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.titleLabel.frame)) / 2.0);
    frame.origin.y = CGRectGetHeight(self.bounds) - kTrophyBottomMargin+37.5;
    self.titleLabel.frame = frame;
}

- (void)setTrophy:(TATrophy *)trophy
{
    _trophy = trophy;
    if (_trophy) {
        // Trophy Image
        PFFile *imageFile = [trophy parseFileForTrophyImage];
        self.trophyImageView.file = imageFile;
        [self.trophyImageView loadInBackground];
        
        // Title
        [self.titleLabel setText:_trophy.caption];
        
        // Date
        /*NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM/dd/yy"];
        [self.dateLabel setText:[format stringFromDate:trophy.time]];*/
        
        // Author
        [self.authorLabel setText:[NSString stringWithFormat:@"Awarded by: %@", trophy.author.name]];
        
        // Action footer
        self.actionFooterView.trophy = trophy;
        
        [self setNeedsLayout];
    }
}

@end
