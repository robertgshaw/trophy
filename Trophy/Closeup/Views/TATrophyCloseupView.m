//
//  TATrophyCloseupView.m
//  Trophy
//
//  Created by Gigster on 1/12/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TATrophyCloseupView.h"
#import "TACommentTableViewController.h"
#import "TATrophyActionFooterView.h"
#import "TABackButton.h"
#import "TAOverlayButton.h"
#import "UIColor+TAAdditions.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "TATrophyManager.h"
#import "TALikesButton.h"
#import "TAOverlayButton.h"


static const CGFloat closeupMargin = 4;

@interface TATrophyCloseupView ()

@property (nonatomic, strong) PFImageView *trophyImageView;
@property (nonatomic, strong) TAOverlayButton *overlay;
@property (nonatomic, strong) UIButton *backgroundTap;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation TATrophyCloseupView

- (instancetype)initWithDelegate:(id<UIScrollViewDelegate, TAFlagButtonDelegate, TABackButtonDelegate, TALikeButtonDelegate, TAOverlayButtonDelegate, TATrophyCloseupViewDelegate>)delegate
{
    self = [super init];
    if (self) {

        self.delegate1 = delegate;
        
        _scrollView = [[UIScrollView alloc] init];
        
        self.scrollView.scrollEnabled = NO;
        self.scrollView.minimumZoomScale = 1.0;
        self.scrollView.maximumZoomScale = 3.0;
        self.scrollView.contentSize = self.trophyImageView.frame.size;
        self.scrollView.delegate = delegate;
        [self addSubview:self.scrollView];
        
        // adds trophy image view
        _trophyImageView = [[PFImageView alloc] init];
        
        // assure that images will not be warped (http://developer.xamarin.com/api/type/MonoTouch.UIKit.UIViewContentMode/)
        self.trophyImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.trophyImageView.clipsToBounds = YES;
        self.trophyImageView.layer.masksToBounds = YES;
        self.trophyImageView.layer.borderColor = [UIColor trophyYellowColor].CGColor;
        self.trophyImageView.layer.borderWidth = 0.0;
        [self.scrollView addSubview:self.trophyImageView];

        
        // enables background tap
        self.backgroundTap = [[UIButton alloc] init];
        [self.backgroundTap addTarget:self action:@selector(backgroundDidTap:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backgroundTap];
        
        // adds back button
        self.backButton = [[TABackButton alloc] initWithFrame:CGRectZero];
        self.backButton.delegate = delegate;
        self.backButton.hidden = NO;
        [self addSubview:self.backButton];
        
        // adds flag button
        self.flagButton = [[TAFlagButton alloc] initWithFrame:CGRectZero];
        self.flagButton.delegate = delegate;
        self.flagButton.hidden = NO;
        [self addSubview:self.flagButton];
        
        // adds overlay
        self.overlay = [[TAOverlayButton alloc] initWithDelegate:delegate];
        self.overlay.hidden = NO;
        [self addSubview:self.overlay];
        
        // configures likes button
        self.likesButton = [[TALikesButton alloc] initWithFrame:CGRectZero];
        self.likesButton.delegate = delegate;
        [self addSubview:self.likesButton];
        
        // configures date label
        self.dateLabel = [[UILabel alloc] init];
        [self.dateLabel setTextAlignment:NSTextAlignmentLeft];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.dateLabel.font = [UIFont fontWithName:@"Avenir-Book" size:16.0];
        [self addSubview:self.dateLabel];
        
        // configures comment button
        self.commentsButton = [[UIButton alloc] init];
        [self.commentsButton setBackgroundImage:[UIImage imageNamed:@"comment-icon"] forState:UIControlStateNormal];
        [self.commentsButton addTarget:self action:@selector(didPressCommentsButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.commentsButton];
        
        self.backgroundColor = [UIColor trophyNavyColor];
        
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat margin = self.bounds.size.width * .07;
    
    // configures image display
    CGRect frame = self.trophyImageView.frame;
    CGFloat height = CGRectGetMaxY(self.frame) * .8;
    CGFloat width = CGRectGetMaxX(self.frame);
    frame.origin.x = (CGRectGetMidX(self.bounds) - floorf(width / 2.0));
    frame.origin.y = CGRectGetMidY(self.frame) - (frame.size.height / 2) + 2;
    frame.size.width = width;
    frame.size.height = height;
    self.trophyImageView.frame = frame;
    
    // lays out the overlay
    frame.size = CGSizeMake(_trophyImageView.bounds.size.width, (self.bounds.size.height * .1));
    frame.origin.x = CGRectGetMinX(self.bounds);
    frame.origin.y = CGRectGetMaxY(self.trophyImageView.frame) - frame.size.height;
    self.overlay.frame = frame;
    
    // lays out the flag button
    frame.size = CGSizeMake(25.0, 25.0);
    frame.origin.x = CGRectGetMaxX(self.bounds) - (frame.size.width) - margin / 2;
    frame.origin.y = CGRectGetMinY(self.trophyImageView.frame) - ((CGRectGetMinY(self.trophyImageView.frame) - CGRectGetMinY(self.bounds)) / 2) - (frame.size.height / 2) + 5;
    self.flagButton.frame = frame;
    
    // lays out the back button
    frame.size = CGSizeMake(25.0, 25.0);
    frame.origin.x = margin / 2;
    frame.origin.y = self.flagButton.frame.origin.y;
    self.backButton.frame = frame;
    
    // lays out the delete button
    frame.size = CGSizeMake(25.0, 25.0);
    frame.origin.x = CGRectGetMinX(self.flagButton.frame) - frame.size.width - 10;
    frame.origin.y = self.flagButton.frame.origin.y;
    self.deleteButton.frame = frame;
        
     // configures date label
    [self.dateLabel sizeToFit];
    frame = self.dateLabel.frame;
    frame.size.height = self.frame.size.height * .08;
    frame.origin.x = CGRectGetMidX(self.bounds) - (self.dateLabel.bounds.size.width / 2);
    frame.origin.y = CGRectGetMaxY(self.bounds) - ((CGRectGetMaxY(self.bounds) - CGRectGetMaxY(self.trophyImageView.frame)) / 2) - (frame.size.height / 2);
    self.dateLabel.frame = frame;

    // configures like button
    frame = self.likesButton.frame;
    frame.size = CGSizeMake([TALikesButton likeButtonWidth], 40.0);
    frame.origin.x = CGRectGetMaxX(self.bounds) - margin - frame.size.width;
    frame.origin.y = CGRectGetMaxY(self.bounds) - ((CGRectGetMaxY(self.bounds) - CGRectGetMaxY(self.trophyImageView.frame)) / 2) - (frame.size.height / 2);
    self.likesButton.frame = frame;
    
    // configures comment button
    frame = self.commentsButton.frame;
    frame.size = CGSizeMake(25.0, 25.0);
    frame.origin.x = CGRectGetMinX(self.likesButton.frame) - frame.size.width - 10;
    frame.origin.y = CGRectGetMaxY(self.bounds) - ((CGRectGetMaxY(self.bounds) - CGRectGetMaxY(self.trophyImageView.frame)) / 2) - (frame.size.height / 2);
    self.commentsButton.frame = frame;
    
    // adds background tap
    self.backgroundTap.frame = self.bounds;
}

// square crop
- (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize {
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    } else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

// configures correct data
- (void)setTrophy:(TATrophy *)trophy
{
    _trophy = trophy;
    if (_trophy) {
        
        // Trophy Image
        PFFile *imageFile = [trophy parseFileForTrophyImage];
        self.trophyImageView.file = imageFile;
        self.trophyImageView.image = [self squareImageFromImage:self.trophyImageView.image scaledToSize:400];
        [self.trophyImageView loadInBackground];
        
        // Title
        [self.overlay.titleLabel setText:_trophy.caption];
        
        // Date
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM/dd/yy"];
        [self.dateLabel setText:[format stringFromDate:trophy.time]];
        
        // "___ AWARDED _____"
        self.overlay.recipientLabel.text = [NSString stringWithFormat:@"%@ awarded %@",trophy.author.name, trophy.recipient.name];
        [self.overlay.recipientLabel setText:self.overlay.recipientLabel.text];
        
        // Likes
        self.likesButton.trophy = trophy;
        
        [self setNeedsLayout];
    }
}

// hides overlay on click
- (void) hideOverlay
{
    self.overlay.hidden = !self.overlay.hidden;
}

// on background tap, hide
- (void)backgroundDidTap:(id)sender
{
    [self.delegate1 hideDisplays];
}

// jumps back to delegate on comment button click
- (void) didPressCommentsButton
{
    [self.delegate1 closeupViewDidPressCommentsButton:self];
    
}

@end

