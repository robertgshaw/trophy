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

#import "UIColor+TAAdditions.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "TATrophyManager.h"


static const CGFloat kTrophyImageSideMargin = 20.0;
static const CGFloat kTrophyImageBottomMargin = 250.0;
static const CGFloat kTrophyImageCornerRadius = 15.0;
static const CGFloat kButtonWidth = 25.0;


@interface TATrophyCloseupView ()

@property (nonatomic, strong) PFImageView *trophyImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *recipientLabel;
@property (nonatomic, strong) UILabel *likesIndicatorLabel;
//@property (nonatomic, strong) UIButton *commentsButton;
@property (nonatomic, strong) UIButton *overlay;
@property (nonatomic, strong) TATrophyActionFooterView *actionFooterView;

@end

@implementation TATrophyCloseupView

- (instancetype)initWithDelegate:(id<TATrophyActionFooterDelegate>)delegate
{
    self = [super init];
    if (self) {
        _trophyImageView = [[PFImageView alloc] init];
        self.trophyImageView.layer.cornerRadius = kTrophyImageCornerRadius;
        self.trophyImageView.layer.masksToBounds = YES;
        self.trophyImageView.clipsToBounds = NO;
        self.trophyImageView.layer.borderColor = [UIColor trophyYellowColor].CGColor;
        self.trophyImageView.layer.borderWidth = 0.0;
        [self addSubview:self.trophyImageView];
        
        _overlay= [[UIButton alloc] init];
        [self.overlay setBackgroundImage:[UIImage imageNamed:@"top-box"] forState:UIControlStateNormal];
        [self.overlay setBackgroundImage:[UIImage imageNamed:@"likes-button"] forState:UIControlStateSelected];
        [self.overlay addTarget:self action:@selector(didPressOverlay) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.overlay];
        
        _titleLabel = [[UILabel alloc] init];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        self.titleLabel.textColor = [UIColor trophyYellowColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.5;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.titleLabel];
        
        _likesIndicatorLabel = [[UILabel alloc] init];
        [self.likesIndicatorLabel setTextAlignment:NSTextAlignmentCenter];
        self.likesIndicatorLabel.textColor = [UIColor trophyYellowColor];
        self.likesIndicatorLabel.font = [UIFont systemFontOfSize:13];
        //fill in "" with "comments or see more"
        self.likesIndicatorLabel.text = @"";
        [self addSubview:self.likesIndicatorLabel];
        
        _dateLabel = [[UILabel alloc] init];
        [self.dateLabel setTextAlignment:NSTextAlignmentCenter];
        self.dateLabel.textColor = [UIColor trophyYellowColor];
        self.dateLabel.font = [UIFont systemFontOfSize:11.0];
        [self addSubview:self.dateLabel];
        
        _recipientLabel = [[UILabel alloc] init];
        [self.recipientLabel setTextAlignment:NSTextAlignmentCenter];
        self.recipientLabel.textColor = [UIColor trophyYellowColor];
        self.recipientLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.recipientLabel];
        
        _actionFooterView = [[TATrophyActionFooterView alloc] initWithFrame:CGRectZero];
        self.actionFooterView.delegate = delegate;
        [self addSubview:self.actionFooterView];
        
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
    
    
    CGRect frame = self.trophyImageView.frame;
    CGSize trophySize = self.trophyImageView.image.size;
    //  CGFloat height = CGRectGetHeight(self.bounds) - kTrophyImageSideMargin - kTrophyImageBottomMargin;
    //CGFloat width = floorf(height / trophySize.height * trophySize.width);
    // how to change photo size
    CGFloat height = CGRectGetMaxY(self.frame) - 110;
    CGFloat width = CGRectGetMaxX(self.frame);
    frame.origin.x = (CGRectGetMidX(self.bounds) - floorf(width / 2.0));
    frame.origin.y = kTrophyImageSideMargin - 20.0;
    frame.size.width = width;
    frame.size.height = height;
    self.trophyImageView.frame = frame;
    
    [self.titleLabel sizeToFit];
    width = CGRectGetWidth(self.bounds) - 30.0;;
    frame = self.titleLabel.frame;
    frame.origin.x = CGRectGetMidX(self.bounds) - floorf(width / 2.0);
    frame.origin.y = CGRectGetMaxY(self.trophyImageView.frame) - 75.0;
    frame.size.width = CGRectGetWidth(self.bounds) - 30.0;
    self.titleLabel.frame = frame;
    
    /*
    frame = self.commentsButton.frame;
    frame.size = CGSizeMake(kButtonWidth, kButtonWidth);
    frame.origin.x = CGRectGetMinX(self.bounds) + 2.5;
    frame.origin.y = CGRectGetMaxY(self.recipientLabel.frame) + 10;
    self.commentsButton.frame = frame;
    */
    
    [self.dateLabel sizeToFit];
    frame = self.dateLabel.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.dateLabel.frame)) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.recipientLabel.frame) + 5.0;
    self.dateLabel.frame = frame;
    
    [self.likesIndicatorLabel sizeToFit];
    frame = self.likesIndicatorLabel.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.likesIndicatorLabel.frame)) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.dateLabel.frame) + 3.0;
    self.likesIndicatorLabel.frame = frame;
    
    [self.recipientLabel sizeToFit];
    frame = self.recipientLabel.frame;
    frame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(self.recipientLabel.frame)) / 2.0);
    frame.origin.y = CGRectGetMaxY(self.titleLabel.frame) + 3.0;
    self.recipientLabel.frame = frame;
    
    frame = self.actionFooterView.frame;
    frame.size = CGSizeMake([TATrophyActionFooterView actionFooterWidth], 20.0);
    frame.origin.x = CGRectGetMaxX(self.bounds) - 30.0;
    frame.origin.y = CGRectGetMaxY(self.recipientLabel.frame) + 37.5;
    self.actionFooterView.frame = frame;
    
    // to enable likes button just undo comment
    /*frame = self.likesButton.frame;
     frame.size = CGSizeMake(kButtonWidth, kButtonWidth);
     //frame.origin.x = kSideMargin;
     frame.origin.x = CGRectGetMidX(self.bounds) - floorf([TATrophyActionFooterView actionFooterWidth] / 2.0)+2;
     frame.origin.y = CGRectGetMaxY(self.recipientLabel.frame) + 5.0+ floorf((20 - kButtonWidth) / 2.0)-24;
     //floorf((CGRectGetHeight(self.bounds) - kButtonWidth) / 2.0)-24;
     self.likesButton.frame = frame;*/
    
    self.overlay.alpha = 0.6;
    frame = self.overlay.frame;
    frame.size = CGSizeMake(500, 200);
    frame.origin.x = CGRectGetMinX(self.bounds);
    frame.origin.y = CGRectGetMaxY(self.titleLabel.frame) - 20.0;
    self.overlay.frame = frame;
    
    
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
        [self.titleLabel setText:_trophy.caption];
        
        // Date
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM/dd/yy"];
        [self.dateLabel setText:[format stringFromDate:trophy.time]];
        
        // Author
        [self.recipientLabel setText:trophy.recipient.name];
        
        //IF YOU WANT "___ AWARDED _____"
        //self.recipientLabel.text = [NSString stringWithFormat:@"%@ awarded %@",trophy.author.name, trophy.recipient.name];
        //[self.recipientLabel setText:self.recipientLabel.text];
        
        // Action footer
        self.actionFooterView.trophy = trophy;
        
        [self setNeedsLayout];
    }
}

@end

