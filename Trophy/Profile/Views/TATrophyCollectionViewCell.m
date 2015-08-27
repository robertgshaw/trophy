//
//  TATrophyCollectionViewCell.m
//  Trophy
//
//  Created by Gigster on 1/18/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TATrophyCollectionViewCell.h"

#import <ParseUI/ParseUI.h>

@interface TATrophyCollectionViewCell ()

@property (nonatomic, strong) PFImageView *trophyImageView;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *authorLabel;
//@property (nonatomic, strong) TATrophyActionFooterView *actionFooterView;
//@property (nonatomic, strong) UILabel *titleLabel;
//@property (nonatomic, strong) UIImageView *trophyIconView;

@end

@implementation TATrophyCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        // configure image view
        _trophyImageView = [[PFImageView alloc] init];
        self.trophyImageView.layer.cornerRadius = 5.0;
        self.trophyImageView.layer.masksToBounds = YES;
        self.trophyImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.trophyImageView.clipsToBounds = YES;
        [self addSubview:self.trophyImageView];
        
        // configure date label
        _dateLabel = [[UILabel alloc] init];
        [self.dateLabel setTextAlignment:NSTextAlignmentCenter];
        self.dateLabel.textColor = [UIColor blackColor];
        self.dateLabel.font = [UIFont fontWithName:@"Avenir-Book" size:13.0];
        [self addSubview:self.dateLabel];
        
        // configure author label
        _authorLabel = [[UILabel alloc] init];
        [self.authorLabel setTextAlignment:NSTextAlignmentCenter];
        self.authorLabel.textColor = [UIColor blackColor];
        self.authorLabel.font = [UIFont fontWithName:@"Avenir-Book" size:13.0];
        [self addSubview:self.authorLabel];
        
//        _titleLabel = [[UILabel alloc] init];
//        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
//        self.titleLabel.textColor = [UIColor blackColor];
//        self.titleLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:12.0];
//        [self addSubview:self.titleLabel];

        
        //this adds like button, commented out because it doesn't look good directly over the photo
//        _actionFooterView = [[TATrophyActionFooterView alloc] initWithFrame:CGRectZero];
//        self.actionFooterView.delegate = self.actionFooterDelegate;
//        [self addSubview:self.actionFooterView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // layout image view
    CGRect frame = self.trophyImageView.frame;
    frame.size = CGSizeMake(self.bounds.size.width * .7, self.bounds.size.height * .85);
    frame.origin.x = CGRectGetMidX(self.bounds) - frame.size.width / 2;
    frame.origin.y = CGRectGetMidY(self.bounds) - frame.size.height / 2;
    self.trophyImageView.frame = frame;
    
    // layout author label
    [self.authorLabel sizeToFit];
    frame = self.authorLabel.frame;
    frame.size.width = self.bounds.size.width * .95;
    frame.size.height = self.bounds.size.height * .075;
    frame.origin.x = CGRectGetMidX(self.bounds) - frame.size.width / 2;
    frame.origin.y = 0;
    self.authorLabel.frame = frame;
    
    // layout date label
    [self.dateLabel sizeToFit];
    frame = self.dateLabel.frame;
    frame.size.width = self.bounds.size.width * .95;
    frame.size.height = self.bounds.size.height * .075;
    frame.origin.x = self.authorLabel.frame.origin.x;
    frame.origin.y = CGRectGetMaxY(self.trophyImageView.frame);
    self.dateLabel.frame = frame;

}

- (void)setTrophy:(TATrophy *)trophy
{
    _trophy = trophy;
    if (_trophy) {
        // Trophy Image
        PFFile *imageFile = [trophy parseFileForTrophyImage];
        self.trophyImageView.file = imageFile;
        [self.trophyImageView loadInBackground];
        
        // Date
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM/dd/yy"];
        [self.dateLabel setText:[format stringFromDate:trophy.time]];
        
        // Author
        [self.authorLabel setText:[NSString stringWithFormat:@"Awarded by: %@", trophy.author.name]];
        
//        // Title
//        [self.titleLabel setText:_trophy.caption];
        
//        // Action footer
//        self.actionFooterView.trophy = trophy;
        
        [self setNeedsLayout];
    }
}

@end
