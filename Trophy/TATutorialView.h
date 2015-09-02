//
//  TATutorialView.h
//  Trophy
//
//  Created by Robert Shaw on 9/1/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TATutorialView : UIView

@property (strong, nonatomic) UIImageView *image;
@property (strong, nonatomic) UILabel *caption;

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image caption:(NSString*)caption;

@end
