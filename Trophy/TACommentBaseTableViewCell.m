//
//  TACommentBaseTableViewCell.m
//  Trophy
//
//  Created by Kenny Okagaki on 6/25/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TACommentBaseTableViewCell.h"
#import "PAPUtility.h"
#import "TATrophy.h"
#import "UIColor+TAAdditions.h"

static const CGFloat imageMargin = 7.5;
static const CGFloat textMargin = 7.5;
static const CGFloat imageSize = 40.0;
static const CGFloat nameHeight = 17.5;

@interface TACommentBaseTableViewCell () {
    BOOL hideSeparator; // True if the separator shouldn't be shown
}
@end

@implementation TACommentBaseTableViewCell
@synthesize mainView;
@synthesize cellInsetWidth;
@synthesize avatarImageView;
@synthesize avatarImageButton;
@synthesize nameButton;
@synthesize contentLabel;
@synthesize timeLabel;
@synthesize separatorImage;
@synthesize delegate;
@synthesize user;

#pragma mark - NSObject

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        cellInsetWidth = 0.0f;
        hideSeparator = YES;
        self.clipsToBounds = YES;
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        
        mainView = [[UIView alloc] initWithFrame:self.contentView.frame];
        [mainView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]]];
        
        self.avatarImageView = [[PFImageView alloc] init];
        self.avatarImageView.backgroundColor = [UIColor whiteColor];
        self.avatarImageView.image = [UIImage imageNamed:@"default-profile-icon"];
        self.avatarImageView.layer.cornerRadius = 20;
        self.avatarImageView.clipsToBounds = YES;
        [mainView addSubview:self.avatarImageView];
        
        self.nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.nameButton setBackgroundColor:[UIColor clearColor]];
        [self.nameButton setTitleColor:[UIColor trophyNavyColor] forState:UIControlStateNormal];
        [self.nameButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12.0f]];
        [self.nameButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.nameButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.nameButton.titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [self.nameButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [mainView addSubview:self.nameButton];
        
        self.contentLabel = [[UILabel alloc] init];
        [self.contentLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:13.0f]];
        [self.contentLabel setTextColor:[UIColor blackColor]];
        [self.contentLabel setNumberOfLines:0];
        [self.contentLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [self.contentLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.70f]];
        [self.contentLabel setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [mainView addSubview:self.contentLabel];
        
        self.timeLabel = [[UILabel alloc] init];
        [self.timeLabel setFont:[UIFont systemFontOfSize:11]];
        [self.timeLabel setTextColor:[UIColor grayColor]];
        [self.timeLabel setBackgroundColor:[UIColor clearColor]];
        [self.timeLabel setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.70f]];
        [self.timeLabel setShadowOffset:CGSizeMake(0, 1)];
        [mainView addSubview:self.timeLabel];
        
        self.avatarImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.avatarImageButton setBackgroundColor:[UIColor clearColor]];
        [self.avatarImageButton addTarget:self action:@selector(didTapUserButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [mainView addSubview:self.avatarImageButton];
        
        self.separatorImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SeparatorComments.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)]];
        [mainView addSubview:separatorImage];
        
        [self.contentView addSubview:mainView];
    }
    
    return self;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [mainView setFrame:CGRectMake(cellInsetWidth, self.contentView.frame.origin.y, self.contentView.frame.size.width - (2 * cellInsetWidth), self.contentView.frame.size.height)];
    
    // lays out image view frame
    CGRect frame = self.avatarImageView.frame;
    frame.size.height = imageSize;
    frame.size.width = frame.size.height;
    frame.origin.x = imageMargin;
    frame.origin.y = imageMargin;
    self.avatarImageView.frame = frame;
    self.avatarImageButton.frame = frame;
    
    // lays out name button frame
    [self.nameButton sizeToFit];
    frame = self.nameButton.frame;
    frame.size.height = nameHeight;
    frame.origin.x = CGRectGetMaxX(self.avatarImageView.frame) + textMargin;
    frame.origin.y = self.avatarImageView.frame.origin.x;
    self.nameButton.frame = frame;
        
    // layout the content
    self.contentLabel.frame = CGRectMake(0, 0, self.mainView.frame.size.width - CGRectGetMaxX(self.avatarImageView.frame) - (textMargin * 2), 0);
    [self.contentLabel sizeToFit];
    frame = self.contentLabel.frame;
    frame.size.width = self.mainView.frame.size.width - CGRectGetMaxX(self.avatarImageView.frame) - (textMargin * 2);
    frame.origin.x = self.nameButton.frame.origin.x;
    frame.origin.y = CGRectGetMaxY(self.nameButton.frame);
    self.contentLabel.frame = frame;
}

- (void)drawRect:(CGRect)rect {
    // Add a drop shadow in core graphics on the sides of the cell
    [super drawRect:rect];
    if (self.cellInsetWidth != 0) {
        [PAPUtility drawSideDropShadowForRect:mainView.frame inContext:UIGraphicsGetCurrentContext()];
    }
}

#pragma mark - Delegate methods

/* Inform delegate that a user image or name was tapped */
- (void)didTapUserButtonAction:(id)sender {
    [self.delegate commentViewDidPressUser:self.user];
}

#pragma mark - PAPBaseTextCell

/* Static helper to get the height for a cell if it had the given name and content */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellWidth:(CGFloat)cellWidth{
    return [TACommentBaseTableViewCell heightForCellWithName:name contentString:content cellInsetWidth:0 cellWidth:cellWidth];
}

/* Static helper to get the height for a cell if it had the given name, content and horizontal inset */
+ (CGFloat)heightForCellWithName:(NSString *)name contentString:(NSString *)content cellInsetWidth:(CGFloat)cellInset cellWidth:(CGFloat)cellWidth {
    
    // get the width of the text based on the size of all other elements
    CGFloat horizontalTextSpace = cellWidth - (cellInset * 2) - imageMargin - imageSize - (textMargin * 2);
    
    // constraints, maximum size of comment is 500 pixels
    CGSize labelContraints = CGSizeMake(horizontalTextSpace, 500.0f);
    
    // context
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    // rectangle size of the string
    CGRect labelRect = [content boundingRectWithSize:labelContraints
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:nil
                                        context:context];
    
    // return the correct size based on if the comment is muli-line or not
    if (labelRect.size.height + (imageMargin * 2) + nameHeight < (imageMargin * 2) + imageSize) {
        return imageMargin * 2 + imageSize;
    } else {
        return (imageMargin * 2) + nameHeight + labelRect.size.height + 15;
    }
}


- (void)setUser:(PFUser *)aUser {
    user = aUser;
    
    // Set name button properties and avatar image
    [self.avatarImageView setFile:[self.user objectForKey:@"profileImage"]];
    [self.avatarImageView loadInBackground];
    [self.nameButton setTitle:[self.user objectForKey:@"name"] forState:UIControlStateNormal];
    [self.nameButton setTitle:[self.user objectForKey:@"name"] forState:UIControlStateHighlighted];
}

- (void)setContentText:(NSString *)contentString {
 
    [self.contentLabel setText:contentString];
}

- (void)setDate:(NSDate *)date {
    //TODO Fix with time formatter from timeline
    /*
     // Set the label with a human readable time
     [self.timeLabel setText:[timeFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:date]];
     [self setNeedsDisplay];
     */
}

- (void)setCellInsetWidth:(CGFloat)insetWidth {
    // Change the mainView's frame to be insetted by insetWidth and update the content text space
    cellInsetWidth = insetWidth;
    [mainView setFrame:CGRectMake(insetWidth, mainView.frame.origin.y, mainView.frame.size.width - (2 * insetWidth), mainView.frame.size.height)];
}

/* Since we remove the compile-time check for the delegate conforming to the protocol
 in order to allow inheritance, we add run-time checks. */
- (id<TACommentBaseTableViewCellDelegate>)delegate {
    return (id<TACommentBaseTableViewCellDelegate>)delegate;
}

- (void)setDelegate:(id<TACommentBaseTableViewCellDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
    }
}

- (void)hideSeparator:(BOOL)hide {
    hideSeparator = YES;
}

@end
