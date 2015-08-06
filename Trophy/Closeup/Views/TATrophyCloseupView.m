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
#import "TALikesButton.h"


static const CGFloat kTrophyImageCornerRadius = 15.0;
static const CGFloat overlayHeight = 150.0;


@interface TATrophyCloseupView ()

@property (nonatomic, strong) PFImageView *trophyImageView;
@property (nonatomic, strong) TAOverlayButton *overlay;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *flagButton;


@end

@implementation TATrophyCloseupView

- (instancetype)initWithDelegate:(id<TALikeButtonDelegate, TAOverlayButtonDelegate, TATrophyCloseupViewDelegate>)delegate
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
        [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
        [self.backButton setTintColor: [UIColor trophyYellowColor]];
        self.backButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backButton];
        
        self.flagButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.flagButton.backgroundColor = [UIColor clearColor];
        self.flagButton.layer.cornerRadius = 5.0;
        [self.flagButton setTitle:@"Flag" forState:UIControlStateNormal];
        [self.flagButton setTintColor: [UIColor trophyYellowColor]];
        self.flagButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.flagButton addTarget:self action:@selector(flagButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.flagButton];
        
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
    frame.size = CGSizeMake(60.0, 25.0);
    frame.origin.x = CGRectGetMidX(self.bounds) - (frame.size.width / 2);
    frame.origin.y = 25;
    self.flagButton.frame = frame;
    
    // lays out the back button
    frame.size = CGSizeMake(60.0, 25.0);
    frame.origin.x = 10.0;
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

// back button action handler
- (void)backButtonPressed:(UIButton *)sender {

    [self.delegate1 backButtonPressed];

}

- (void)flagButtonPressed:(id *)sender {
    
    // alert - yes/no for flag
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flag Trophy" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil]; [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) { // Set buttonIndex == 0 to handel "Ok"/"Yes" button response
        // Ok button response
        
        //Query parse
        PFQuery *query = [PFQuery queryWithClassName:@"Trophy"];
        [query whereKey:@"objectId" equalTo: [self.trophy getTrophyAsParseObject].objectId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError *error) {
            if (!error) {
                // The find succeeded.
                
               //flag function
                [object setObject:[NSNumber numberWithBool:YES] forKey:@"flag"];
                
                [object saveInBackground];
                NSLog(@"Successfully flagged. This trophy will be reviewed for removal.");
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
    }
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
        self.overlay.recipientLabel.text = [NSString stringWithFormat:@"%@ awarded %@",trophy.author.name, trophy.recipient.name];
        [self.overlay.recipientLabel setText:self.overlay.recipientLabel.text];
        
        // Likes
        self.overlay.likesButton.trophy = trophy;
        
        [self setNeedsLayout];
    }
}

@end

