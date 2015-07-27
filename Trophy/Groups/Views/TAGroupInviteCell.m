//
//  TAGroupInviteCell.m
//  Trophy
//
//  Created by Gigster on 1/26/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAGroupInviteCell.h"

#import "UIColor+TAAdditions.h"

@interface TAGroupInviteCell ()

@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation TAGroupInviteCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _sendButton = [[UIButton alloc] init];
        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        self.sendButton.titleLabel.textColor = [UIColor whiteColor];
        [self.sendButton addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.sendButton.backgroundColor = [UIColor standardBlueButtonColor];
        self.sendButton.layer.cornerRadius = 5.0;
        self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        [self.sendButton sizeToFit];
        CGRect frame = self.sendButton.bounds;
        frame.size.width += 20;
        self.sendButton.frame = CGRectIntegral(frame);
        self.accessoryView = self.sendButton;
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.textLabel setText:@""];
    [self.detailTextLabel setText:@""];
    _contact = nil;
}

- (void)sendButtonPressed:(id)sender
{
    [self.delegate groupInviteCellDidPressSend:self];
}

- (void)setContact:(TAFriendContact *)contact
{
    _contact = contact;
    self.textLabel.text = contact.fullName;
    self.detailTextLabel.text = contact.phoneNumbers[0];
    [self setNeedsLayout];
}

@end
