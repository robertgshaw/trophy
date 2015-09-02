//
//  TATutorialView.m
//  Trophy
//
//  Created by Robert Shaw on 9/1/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TATutorialView.h"

@implementation TATutorialView

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image caption:(NSString*)caption {
    self = [super initWithFrame:frame];
    if (self) {
        // configures image
        self.image = [[UIImageView alloc] initWithImage:image];
        self.image.contentMode = UIViewContentModeScaleAspectFill;
        self.image.clipsToBounds = YES;
        [self addSubview:self.image];
        
        // configures caption
        self.caption = [[UILabel alloc] init];
        self.caption.textAlignment = NSTextAlignmentCenter;
        self.caption.textColor = [UIColor whiteColor];
        self.caption.font = [UIFont fontWithName:@"Avenir" size:20.0];
        self.caption.numberOfLines = 3;
        self.caption.lineBreakMode = NSLineBreakByTruncatingTail;
        self.caption.text = caption;
        [self addSubview:self.caption];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect frame = self.caption.frame;
    frame.size.width = self.frame.size.width * .8;
    frame.size.height = self.frame.size.height * .15;
    frame.origin.x = CGRectGetMidX(self.bounds) - frame.size.width / 2;
    frame.origin.y = self.frame.size.height * .025;
    self.caption.frame = frame;
    
    NSLog(@"%@", NSStringFromCGRect(self.caption.frame));
    
    frame = self.image.frame;
    frame.size.width = self.frame.size.width * .9;
    frame.size.height = [self formatHeightFromSize:self.image.image.size withWidth:frame.size.width];
    frame.origin.x = self.frame.size.width * .1;
    frame.origin.y = 150;
    self.image.frame = frame;
    
//   NSLog(@"%@", NSStringFromCGRect(self.image.frame));
    
}

- (CGFloat)formatHeightFromSize:(CGSize)dimensions withWidth:(CGFloat)width
{
    // format photo height based on width
    return (width / dimensions.width) * dimensions.height;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
