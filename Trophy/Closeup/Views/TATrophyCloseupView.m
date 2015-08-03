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

#import "UIColor+TAAdditions.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "TATrophyManager.h"


static const CGFloat kTrophyImageSideMargin = 20.0;
static const CGFloat kTrophyImageBottomMargin = 250.0;
static const CGFloat kTrophyImageCornerRadius = 15.0;
static const CGFloat kButtonWidth = 25.0;

static const CGFloat overlayWidth = 500.0;
static const CGFloat overlayHeight = 150.0;
static const CGFloat uiTabBarHeight = 39.0;

@interface TATrophyCloseupView ()

@property (nonatomic, strong) PFImageView *trophyImageView;

@property (nonatomic, strong) UIButton *likesIndicatorLabel;
@property (nonatomic, strong) TAOverlayButton *overlay;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation TATrophyCloseupView

- (instancetype)initWithDelegate:(id<TATrophyActionFooterDelegate, TAOverlayButtonDelegate, TATrophyCloseupViewDelegate>)delegate
{
    self = [super init];
    if (self) {

        self.delegate1 = delegate;
        
        _trophyImageView = [[PFImageView alloc] init];
        self.trophyImageView.layer.cornerRadius = kTrophyImageCornerRadius;
        self.trophyImageView.layer.masksToBounds = YES;
        self.trophyImageView.clipsToBounds = NO;
        self.trophyImageView.layer.borderColor = [UIColor trophyYellowColor].CGColor;
        self.trophyImageView.layer.borderWidth = 0.0;
        [self addSubview:self.trophyImageView];
        
        self.backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //[self.backButton setBackgroundImage:[UIImage imageNamed:@"left-arrow"] forState:UIControlStateNormal];

        [self.backButton setFrame:CGRectMake(0, 0, 80, 80)];
        //self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
        [self.backButton setTintColor: [UIColor trophyYellowColor]];
        [self.backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backButton];

        self.overlay = [[TAOverlayButton alloc] initWithDelegate:delegate];
        [self addSubview:self.overlay];
        
        self.backgroundColor = [UIColor blackColor];
        /*
        _commentsButton = [[UIButton alloc] init];
        [self.commentsButton setBackgroundImage:[UIImage imageNamed:@"commentButton"] forState:UIControlStateNormal];
        [self.commentsButton addTarget:self action:@selector(didPressCommentsButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.commentsButton];
        */
        
        
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // configures image display
    CGRect frame = self.trophyImageView.frame;
    
   CGFloat height = CGRectGetMaxY(self.frame) * 8 / 10;
    //CGFloat height = CGRectGetMaxY(self.frame);
    CGFloat width = CGRectGetMaxX(self.frame);
    frame.origin.x = (CGRectGetMidX(self.bounds) - floorf(width / 2.0));
   frame.origin.y = CGRectGetMaxY(self.frame) * 1 / 10;
    //frame.origin.y = 0;
    frame.size.width = width;
    frame.size.height = height;
    self.trophyImageView.frame = frame;
    
    // lays out the overlay
    frame.size = CGSizeMake(_trophyImageView.bounds.size.width, overlayHeight);
    frame.origin.x = CGRectGetMinX(self.bounds);
    frame.origin.y = CGRectGetMaxY(self.bounds) - overlayHeight;
    self.overlay.frame = frame;
    
    /*
    frame = self.commentsButton.frame;
    frame.size = CGSizeMake(kButtonWidth, kButtonWidth);
    frame.origin.x = CGRectGetMinX(self.bounds) + 2.5;
    frame.origin.y = CGRectGetMaxY(self.recipientLabel.frame) + 10;
    self.commentsButton.frame = frame;
    */

    
    // to enable likes button just undo comment
    /*frame = self.likesButton.frame;
     frame.size = CGSizeMake(kButtonWidth, kButtonWidth);
     //frame.origin.x = kSideMargin;
     frame.origin.x = CGRectGetMidX(self.bounds) - floorf([TATrophyActionFooterView actionFooterWidth] / 2.0)+2;
     frame.origin.y = CGRectGetMaxY(self.recipientLabel.frame) + 5.0+ floorf((20 - kButtonWidth) / 2.0)-24;
     //floorf((CGRectGetHeight(self.bounds) - kButtonWidth) / 2.0)-24;
     self.likesButton.frame = frame;*/
    
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

- (void)backButtonPressed:(UIButton *)sender {

    [self.delegate1 backButtonPressed];

}

- (void)didPressCommentsButton:(id)sender
{
    //
    // Disabled because button is acting as watermark
    /*if (self.likesButton.selected) {
     self.likesButton.selected = NO;
     } else {
     self.likesButton.selected = YES;
     }
     TATrophy *updatedTrophy = [[TATrophyManager sharedManager] likeTrophy:self.trophy];
     self.trophy = updatedTrophy;*/
    
    [self.delegate1 closeupViewDidPressCommentsButton:self];
}
- (void)didPressOverlay
{
    //swag
}
-(void)didPressCommentsButton
{
    //swag
}
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
        
        // Author
        //[self.overlay.recipientLabel setText:trophy.recipient.name];
        
        //IF YOU WANT "___ AWARDED _____"
        self.overlay.recipientLabel.text = [NSString stringWithFormat:@"%@ awarded %@",trophy.author.name, trophy.recipient.name];
        [self.overlay.recipientLabel setText:self.overlay.recipientLabel.text];
        
        // Action footer
        self.overlay.actionFooterView.trophy = trophy;
        
        [self setNeedsLayout];
    }
}

@end

