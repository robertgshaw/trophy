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
#import "TAOverlayButton.h"
#import "TABackButton.h"
#import "TAFlagButton.h"

#import "UIColor+TAAdditions.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "TATrophyManager.h"
#import "TALikesButton.h"


static const CGFloat kTrophyImageCornerRadius = 15.0;
static const CGFloat overlayHeight = 140.0;
static const CGFloat closeupMargin = 10.0;

@interface TATrophyCloseupView ()

@property (nonatomic, strong) PFImageView *trophyImageView;
@property (nonatomic, strong) TAOverlayButton *overlay;
@property (nonatomic, strong) TABackButton *backButton;
@property (nonatomic, strong) TAFlagButton *flagButton;


@end

@implementation TATrophyCloseupView

- (instancetype)initWithDelegate:(id<TAFlagButtonDelegate, TABackButtonDelegate, TALikeButtonDelegate, TAOverlayButtonDelegate, TATrophyCloseupViewDelegate>)delegate
{
    self = [super init];
    if (self) {

        self.delegate1 = delegate;
        
        // adds trophy image view
        _trophyImageView = [[PFImageView alloc] init];
        
        // assure that images will not be warped (http://developer.xamarin.com/api/type/MonoTouch.UIKit.UIViewContentMode/)
        self.trophyImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.trophyImageView.clipsToBounds = YES;
        self.trophyImageView.layer.cornerRadius = 5.0;
        self.trophyImageView.layer.masksToBounds = YES;
        self.trophyImageView.layer.borderColor = [UIColor trophyYellowColor].CGColor;
        self.trophyImageView.layer.borderWidth = 0.0;
        [self addSubview:self.trophyImageView];
        
        // adds back button
        self.backButton = [[TABackButton alloc] initWithFrame:CGRectZero];
        [self.backButton setTintColor:[UIColor trophyYellowColor]];
        self.backButton.delegate = delegate;
        [self addSubview:self.backButton];
        
        // adds flag button
        self.flagButton = [[TAFlagButton alloc] initWithFrame:CGRectZero];
        [self.backButton setTintColor:[UIColor trophyYellowColor]];
        self.flagButton.delegate = delegate;
        [self addSubview:self.flagButton];
        
        // adds overlay
        self.overlay = [[TAOverlayButton alloc] initWithDelegate:delegate];
        [self addSubview:self.overlay];
        
        self.backgroundColor = [UIColor blackColor];
        
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // configures image display
    CGRect frame = self.trophyImageView.frame;
    CGFloat height = CGRectGetMaxY(self.frame) * 8 / 10;
    CGFloat width = CGRectGetMaxX(self.frame);
    frame.origin.x = (CGRectGetMidX(self.bounds) - floorf(width / 2.0));
    frame.origin.y = CGRectGetMaxY(self.frame) * 1 / 10;
    frame.size.width = width;
    frame.size.height = height;
    self.trophyImageView.frame = frame;
    
    // lays out the overlay
    frame.size = CGSizeMake(_trophyImageView.bounds.size.width, overlayHeight);
    frame.origin.x = CGRectGetMinX(self.bounds);
    frame.origin.y = CGRectGetMaxY(self.bounds) - overlayHeight;
    self.overlay.frame = frame;
    
    // lays out the flag button
    frame.size = CGSizeMake(70.0, 25.0);
    frame.origin.x = CGRectGetMaxX(self.bounds) - (frame.size.width);
    frame.origin.y = 25;
    self.flagButton.frame = frame;
    
    // lays out the back button
    frame.size = CGSizeMake(70.0, 25.0);
    frame.origin.x = closeupMargin;
    frame.origin.y = 25.0;
    self.backButton.frame = frame;
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
        [self.overlay.dateLabel setText:[format stringFromDate:trophy.time]];
        
        // "___ AWARDED _____"
        self.overlay.recipientLabel.text = [NSString stringWithFormat:@"%@ awarded %@ for:",trophy.author.name, trophy.recipient.name];
        [self.overlay.recipientLabel setText:self.overlay.recipientLabel.text];
        
        // Likes
        self.overlay.likesButton.trophy = trophy;
        
        [self setNeedsLayout];
    }
}

@end

