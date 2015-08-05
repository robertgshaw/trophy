//
//  TATimelineTableViewCell.m
//  Trophy
//
//  Created by Gigster on 12/29/14.
//  Copyright (c) 2014 Gigster. All rights reserved.
//

#import "TATimelineTableViewCell.h"

#import "TATrophyActionFooterView.h"

#import "TACommentTableViewController.h"

#import "TACommentButton.h"

#import "UIColor+TAAdditions.h"
#import <Foundation/Foundation.h>
#import <ParseUI/ParseUI.h>
#import <QuartzCore/QuartzCore.h>

static const CGFloat kCellSideMargin = 20.0;
static const CGFloat kCellTrophyImageWidth = 30.0;
static const CGFloat kCellRecipientImageWidth = 100.0;
static const CGFloat kCellInnerMargin = 10.0;

@interface TATimelineTableViewCell () <TATrophyActionFooterDelegate>

@property (nonatomic, strong) UILabel *recipientLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) PFImageView *trophyImageView;
@property (nonatomic, strong) UIImageView *trophyFrameView;
@property (nonatomic, strong) UIButton *trophyPhoto;
@property (nonatomic, strong) PFImageView *recipientImageView;
@property (nonatomic, strong) TATrophyActionFooterView *actionFooterView;

@end

@implementation TATimelineTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _trophyImageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, kCellTrophyImageWidth, kCellTrophyImageWidth)];
        // this is the wierd black box on top left
        self.trophyImageView.backgroundColor = [UIColor clearColor];
        self.trophyImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.trophyImageView.clipsToBounds = YES;
        [self addSubview:self.trophyImageView];
        
        /* THIS IS DELETED TROPHY PIC
        _trophyFrameView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trophy-timeline-icon"]];
        [self addSubview:self.trophyFrameView];
         */
         
         
        
        _trophyPhoto = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kCellRecipientImageWidth, kCellRecipientImageWidth)];
        [self.trophyPhoto setBackgroundImage:[UIImage imageNamed:@"default-profile-icon"] forState:UIControlStateNormal];
        self.trophyPhoto.backgroundColor = [UIColor whiteColor];
        self.trophyPhoto.layer.borderWidth = 3.0f;
        self.trophyPhoto.layer.borderColor = [UIColor trophyYellowColor].CGColor;
        self.trophyPhoto.layer.cornerRadius = floorf(kCellRecipientImageWidth / 2.0);
        self.trophyPhoto.clipsToBounds = YES;
        //[self.trophyPhoto addTarget:self action:@selector(profileButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = self.trophyPhoto;
             
        _recipientImageView = [[PFImageView alloc] initWithFrame:self.trophyPhoto.bounds];
        self.recipientImageView.alpha = 2.0;
        self.accessoryView = self.recipientImageView;
        //[self.trophyPhoto addSubview:self.recipientImageView];

        
        _recipientLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.recipientLabel.textColor = [UIColor darkGrayColor];
        self.recipientLabel.font = [UIFont systemFontOfSize:13.0];
        self.recipientLabel.numberOfLines = 1;
        [self addSubview:self.recipientLabel];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.dateLabel.textColor = [UIColor trophyYellowColor];
        self.dateLabel.font = [UIFont systemFontOfSize:10.0];
        self.dateLabel.numberOfLines = 1;
        [self addSubview:self.dateLabel];
        
        _commentsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.commentsLabel.textColor = [UIColor darkGrayColor];
//        self.commentsLabel.font = [UIFont systemFontOfSize:10.0];
        self.commentsLabel.font = [UIFont boldSystemFontOfSize:10.0];
        self.commentsLabel.numberOfLines = 1;
        [self addSubview:self.commentsLabel];
        
        self.commentsButton = [[TACommentButton alloc] init];
        [self addSubview:self.commentsButton];

        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.descriptionLabel.numberOfLines = 0;
        self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.descriptionLabel.textColor = [UIColor darkGrayColor];
        self.descriptionLabel.font = [UIFont systemFontOfSize:13.5];
        [self addSubview:self.descriptionLabel];

        _authorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.authorLabel.numberOfLines = 0;
        self.authorLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.authorLabel.textColor = [UIColor darkGrayColor];
        self.authorLabel.font = [UIFont boldSystemFontOfSize:10.0];
        [self addSubview:self.authorLabel];

        _actionFooterView = [[TATrophyActionFooterView alloc] initWithFrame:CGRectZero];
        self.actionFooterView.delegate = self;
        [self addSubview:self.actionFooterView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGPoint center = self.accessoryView.center;
    center.y = CGRectGetMinY(self.descriptionLabel.frame) + floorf(self.descriptionLabel.font.lineHeight / 2.0);
    self.accessoryView.center = center;
    
    if (self.trophy) {
        [self layoutCellViews];
    }
}

- (void)layoutCellViews
{
    CGFloat maxWidth = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.trophyFrameView.frame) - CGRectGetWidth(self.accessoryView.frame) - 2 * kCellInnerMargin - 2 * kCellSideMargin;
    
    // There is no recipient label in text, we use this as a place holder to hold the frame size
    [self.recipientLabel sizeToFit];
    CGRect frame = self.recipientLabel.frame;
    frame.origin.x = kCellSideMargin + CGRectGetWidth(self.trophyFrameView.frame) + kCellInnerMargin;
    frame.origin.y = kCellSideMargin + 60;
    frame.size.width = maxWidth;
    self.recipientLabel.frame = frame;
    
   
    
    //this is the actual trophy photo
    [self.recipientImageView sizeToFit];
    frame.origin.x = CGRectGetMaxX(self.bounds) - 100;
    frame.origin.y = 8;
    self.recipientImageView.frame = frame;
    frame = self.recipientImageView.frame;
    frame.size = CGSizeMake(90,112.5);
    self.recipientImageView.frame = frame;
    //self.recipientImageView.center = CGPointMake(self.recipientImageView.center.x, self.recipientImageView.center.y - 10.0);
    
    [self.dateLabel sizeToFit];
    frame = self.dateLabel.frame;
    frame.origin.x = (kCellSideMargin + CGRectGetWidth(self.trophyFrameView.frame) + (kCellInnerMargin*14));
    frame.origin.y = kCellSideMargin * 5.4;
    frame.size.width = maxWidth;
    self.dateLabel.frame = frame;
    
    [self.descriptionLabel sizeToFit];
    CGSize textSize = CGSizeMake(maxWidth, 150);
    NSDictionary *attributes = @{NSForegroundColorAttributeName:self.descriptionLabel.textColor,
                                 NSFontAttributeName:self.descriptionLabel.font};
    CGRect boundRect = [self.descriptionLabel.text boundingRectWithSize:textSize
                                                                options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                             attributes:attributes
                                                                context:nil];
    frame = self.descriptionLabel.frame;
    frame.origin.x = CGRectGetMinX(self.recipientLabel.frame);
    frame.origin.y = CGRectGetMaxY(self.recipientLabel.frame) - 50.0;
    frame.size = boundRect.size;
    self.descriptionLabel.frame = frame;

    [self.authorLabel sizeToFit];
    frame = self.authorLabel.frame;
    frame.origin.x = kCellSideMargin + CGRectGetWidth(self.trophyFrameView.frame) + kCellInnerMargin;
    frame.origin.y = kCellSideMargin;
    frame.size.width = maxWidth;
    self.authorLabel.frame = frame;

    frame = self.actionFooterView.frame;
    frame.size = CGSizeMake([TATrophyActionFooterView actionFooterWidth], 70.0);
    //frame.origin.x = CGRectGetMinX(self.recipientLabel.frame) + 5.0;
    frame.origin.x =0;
    //frame.origin.y = CGRectGetMaxY(self.descriptionLabel.frame) ;
    frame.origin.y = CGRectGetMaxY(self.descriptionLabel.frame) + (2.4 * kCellInnerMargin)-50;
    self.actionFooterView.frame = frame;

    frame = self.trophyFrameView.frame;
    frame.origin.x = kCellSideMargin;
    frame.origin.y = CGRectGetMinY(self.descriptionLabel.frame) + floorf(self.descriptionLabel.font.lineHeight / 2.0) -25;
    self.trophyFrameView.frame = frame;
    frame = self.trophyImageView.frame;
    frame.size = CGSizeMake(kCellTrophyImageWidth, kCellTrophyImageWidth);
    self.trophyImageView.frame = frame;
    self.trophyImageView.center = CGPointMake(self.trophyFrameView.center.x, self.trophyFrameView.center.y - 10.0);
    
    // set frame on commentsLabel and place label at front of subview
    [self.commentsLabel sizeToFit];
    frame = self.commentsLabel.frame;
    frame.origin.x = (CGRectGetWidth(self.trophyFrameView.frame) + kCellInnerMargin*5);
    frame.origin.y = kCellSideMargin*5.4;
    self.commentsLabel.frame = frame;
    [self bringSubviewToFront:self.commentsLabel];
    
    // set frame on commentsButton and place button at front of subview
    frame = self.commentsButton.frame;
    frame.origin.x = (CGRectGetWidth(self.trophyFrameView.frame) + kCellInnerMargin*2 + 7);
    frame.origin.y = kCellSideMargin*5.2;
// alternative positioning for comments button
//    frame.origin.x = 5;
//    frame.origin.y = kCellSideMargin*4.2;
    frame.size.height = 18;
    frame.size.width = 18;
    self.commentsButton.frame = frame;
    [self bringSubviewToFront:self.commentsButton];
    
}

- (CGFloat)heightOfCell
{
    return CGRectGetMaxY(self.actionFooterView.frame) + kCellSideMargin;
}

- (NSString *)formatDate:(NSDate *)date
{
    NSDate *currentDate = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    
    NSDateComponents *components = [gregorian components:unitFlags
                                                fromDate:date
                                                  toDate:currentDate options:0];
    
    NSInteger timeUnit;
    NSString *unitString;
    if ([components year] > 0) {
        timeUnit = [components year];
        unitString = @"year";
    } else if ([components month] > 0) {
        timeUnit = [components month];
        unitString = @"month";
    } else if ([components day] > 0) {
        NSInteger days = [components day];
        if (days > 7) {
            timeUnit = (int)floor(days / 7);
            unitString = @"week";
        } else {
            unitString = @"day";
            timeUnit = days;
        }
    } else if ([components hour] > 0) {
        timeUnit = [components hour];
        unitString = @"hour";
    } else {
        timeUnit = [components minute];
        unitString = @"minute";
    }
    NSString *format = (timeUnit > 1 || timeUnit == 0) ? @"%ld %@s ago" : @"%ld %@ ago";
    return [NSString stringWithFormat:format, timeUnit, unitString];
}

- (void)setTrophy:(TATrophy *)trophy
{
    
    _trophy = trophy;
    self.recipientLabel.text = [NSString stringWithFormat:@" "];
    self.descriptionLabel.text = trophy.caption;
    self.authorLabel.text = [NSString stringWithFormat:@"%@ awarded %@ for:",trophy.author.name, trophy.recipient.name];
    self.actionFooterView.trophy = trophy;
    self.dateLabel.text = [NSString stringWithFormat:@"%@" , [self formatDate:trophy.time]];
    
    /* THIS IS DELETED PROF PIC
    PFFile *imageFile = [trophy.recipient parseFileForProfileImage];
    self.trophyImageView.file = imageFile;
    [self.trophyImageView loadInBackground];
    */
    
    PFFile *profileImageFile =[trophy parseFileForTrophyImage];
    self.recipientImageView.file = profileImageFile;
    self.recipientImageView.alpha = 1.0;
    self.trophyPhoto.layer.borderWidth = 0.0;
    self.recipientImageView.layer.cornerRadius = 3.0;
    self.recipientImageView.clipsToBounds = YES;
    [self.recipientImageView loadInBackground];
    
    [self layoutCellViews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*- (void)profileButtonTapped:(id)sender
{
    [self.delegate timelineCellDidPressProfileButton:self forUser:self.trophy.recipient];
}*/


#pragma mark - TATimelineActionFooterView Delegate

- (void)trophyActionFooterDidPressLikesButton
{
    
}

- (void)trophyActionFooterDidPressCommentsButton
{

}

- (void)trophyActionFooterDidPressAddButton
{

}

@end
