//
//  UIColor+TAAdditions.m
//  Trophy
//
//  Created by Gigster on 2/10/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "UIColor+TAAdditions.h"

@implementation UIColor (TAAdditions)

+ (UIColor *)trophyYellowColor {
    return [UIColor colorWithRed:0.98 green:0.808 blue:0.184 alpha:1];
}

+ (UIColor *)darkYellowColor {
    return [UIColor colorWithRed:0.922 green:0.757 blue:0.173 alpha:1];
}

+ (UIColor *)standardBlueButtonColor {
    return [UIColor colorWithRed:0.047 green:0.855 blue:0.973 alpha:1];
}

+ (UIColor *)darkerBlueColor {
    return [UIColor colorWithRed:77/255.0f green:159/255.0f blue:252/255.0f alpha:1];
}

+ (UIColor *)mediumTranslucentWhite {
    return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
}

+ (UIColor *)highTranslucentWhite {
    return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75];
}

+ (UIColor *)unselectedGrayColor {
    return [UIColor colorWithRed:0.812 green:0.82 blue:0.82 alpha:1];
}
+ (UIColor *)trophyNavyColor {
    return [UIColor colorWithRed:50/255.0f green:80/255.0f blue:109/255.0f alpha:1.0f];
}

+ (UIColor *)trophyNavyTranslucentColor {
    return [UIColor colorWithRed:50/255.0f green:80/255.0f blue:109/255.0f alpha:0.5f];
}

+ (UIFont *)avenirFont {
    return [UIFont fontWithName:@"Avenir-Book" size:12.0];
}
+ (UIColor *)trophyRedColor {
    return 	[UIColor colorWithRed:0.9373 green:0.4784 blue:0.4784 alpha:1.0f];
}
+ (UIColor *)trophyLightGrayColor {
    return [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.4];
}

@end
