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

@interface TATimelineTableViewCell ()

@end

@implementation TATimelineTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // assure that images will not be warped (http://developer.xamarin.com/api/type/MonoTouch.UIKit.UIViewContentMode/)
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.layer.cornerRadius = 5.0;
        self.imageView.layer.borderWidth = 1.0;
        self.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.imageView.layer.masksToBounds = YES;
        
        // configures vertical gray bar
        self.verticalBar = [[UIView alloc] init];
        self.verticalBar.backgroundColor = [UIColor grayColor];
        [self addSubview:self.verticalBar];
        
        // configures date label
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.dateLabel.textColor = [UIColor whiteColor];
        self.dateLabel.backgroundColor = [UIColor trophyNavyColor];
        self.dateLabel.font = [UIFont fontWithName:@"Avenir-Book" size:10.0];
        self.dateLabel.numberOfLines = 1;
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.dateLabel];
        
        // configures overlay
        self.overlay = [[UIView alloc] init];
        self.overlay.backgroundColor = [UIColor trophyNavyColor];
        self.overlay.layer.cornerRadius = 5.0;
        self.overlay.layer.masksToBounds = YES;
        [self addSubview:self.overlay];
        
        // configures comments
        _commentsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.commentsLabel.textColor = [UIColor trophyYellowColor];
        self.commentsLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:10.0];
        self.commentsLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.commentsLabel.textAlignment = NSTextAlignmentRight;
        
        self.commentsLabel.numberOfLines = 1;
        [self addSubview:self.commentsLabel];
        self.commentsButton = [[UIButton alloc] init];
        [self addSubview:self.commentsButton];

        // configures description
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.descriptionLabel.numberOfLines = 1;
        self.descriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.descriptionLabel.textColor = [UIColor whiteColor];
        self.descriptionLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:12.5];
        [self addSubview:self.descriptionLabel];

        // configures awarded to... logo
        _authorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.authorLabel.numberOfLines = 1;
        self.authorLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.authorLabel.textColor = [UIColor whiteColor];
        self.authorLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:11.5];
        [self addSubview:self.authorLabel];

        // configures likes button
        self.likesButton = [[TALikesButton alloc] initWithFrame:CGRectZero];
        self.likesButton.delegate = self.delegate;
        [self addSubview:self.likesButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // formats date label
    [self.dateLabel sizeToFit];
    CGRect frame = self.dateLabel.frame;
    frame.origin.x = 0;
    frame.origin.y = 10;
    frame.size.height = 20;
    frame.size.width = 40;
    self.dateLabel.frame = frame;
    
    // formats image
    frame = self.imageView.frame;
    frame.size.width = self.frame.size.width - self.dateLabel.frame.size.width - 10;
    frame.size.height = frame.size.width * 1.3;
    frame.origin.x = CGRectGetMaxX(self.dateLabel.frame);
    frame.origin.y = 7;
    self.imageView.frame = frame;
    
    // formats vertical bar
    frame = self.verticalBar.frame;
    frame.size.height = self.frame.size.height;
    frame.size.width = 2;
    frame.origin.x = CGRectGetMidX(self.dateLabel.frame) - (frame.size.width / 2);
    frame.origin.y = 0;
    self.verticalBar.frame = frame;
    
    // formats overlay
    frame = self.overlay.frame;
    frame.size.height = self.imageView.frame.size.height / 5;
    frame.size.width = self.imageView.frame.size.width * .95;
    frame.origin.x = CGRectGetMidX(self.imageView.frame) - (frame.size.width / 2);
    frame.origin.y = CGRectGetMaxY(self.imageView.frame) * .975 - frame.size.height;
    self.overlay.frame = frame;
    
    CGFloat kOverLayMargin = frame.size.height / 20;
    
    // formats likes button, inside overlay
    [self.likesButton sizeToFit];
    frame = self.likesButton.frame;
    frame.origin.x = CGRectGetMinX(self.overlay.frame) + kOverLayMargin;
    frame.origin.y = CGRectGetMidY(self.overlay.frame) - (frame.size.height / 2) - 5;
    self.likesButton.frame = frame;

    // formats author label, inside overlay
    [self.authorLabel sizeToFit];
    frame = self.authorLabel.frame;
    frame.origin.x = CGRectGetMaxX(self.likesButton.frame) + 7.5;
    frame.origin.y = CGRectGetMinY(self.overlay.frame) + self.overlay.frame.size.height * .15;
    frame.size.width = self.overlay.frame.size.width * .8;
    self.authorLabel.frame = frame;
    
    // formats description/ caption label, inside overlay
    [self.descriptionLabel sizeToFit];
    frame = self.descriptionLabel.frame;
    frame.origin.x = CGRectGetMinX(self.authorLabel.frame);
    frame.origin.y = CGRectGetMaxY(self.authorLabel.frame) + 4;
    frame.size.width = self.authorLabel.frame.size.width;
    self.descriptionLabel.frame = frame;
    
    // formats comments button/ label
    [self.commentsLabel sizeToFit];
    frame = self.commentsLabel.frame;
    frame.size.width = self.overlay.frame.size.width * .3;
    frame.origin.x = CGRectGetMaxX(self.overlay.frame) - frame.size.width - kOverLayMargin * 2;
    frame.origin.y = CGRectGetMaxY(self.overlay.frame) - frame.size.height - kOverLayMargin * 2;
    self.commentsLabel.frame = frame;
    
    // puts comment button as the label
    self.commentsButton.frame = frame;
}

+ (CGFloat)formatHeightFromSize:(CGSize)dimensions withWidth:(CGFloat)width
{
    // format photo height based on width
    return (width / dimensions.width) * dimensions.height;
}

- (CGFloat)heightOfCell
{
    return CGRectGetMaxY(self.imageView.frame) + 2;
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
            unitString = @"w";
        } else {
            unitString = @"d";
            timeUnit = days;
        }
    } else if ([components hour] > 0) {
        timeUnit = [components hour];
        unitString = @"hr";
    } else {
        timeUnit = [components minute];
        unitString = @"min";
    }
    NSString *format = (timeUnit > 1 || timeUnit == 0) ? @"%ld %@s" : @"%ld %@";
    return [NSString stringWithFormat:format, timeUnit, unitString];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
